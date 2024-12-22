{
  config,
  lib,
  globals,
  ...
}:
let
  shares = lib.removeAttrs config.services.samba.settings [ "global" ];
in
{
  services.samba-wsdd = {
    enable = true; # make shares visible for windows 10 clients
    openFirewall = true;
  };

  age.secrets.resticpasswd = {
    generator.script = "alnum";
  };
  age.secrets.resticHetznerSsh = {
    generator.script = "ssh-ed25519";
  };
  services.restic.backups = {
    main = {
      user = "root";
      timerConfig = {
        OnCalendar = "06:00";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
      initialize = true;
      passwordFile = config.age.secrets.resticpasswd.path;
      hetznerStorageBox = {
        enable = true;
        inherit (globals.hetzner) mainUser;
        inherit (globals.hetzner.users.smb) subUid path;
        sshAgeSecret = "resticHetznerSsh";
      };
      paths = [ "/bunker" ];
      ##pruneOpts = [
      ##  "--keep-daily 10"
      ##  "--keep-weekly 7"
      ##  "--keep-monthly 12"
      ##  "--keep-yearly 75"
      ##];
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    winbindd.enable = false;
    nmbd.enable = false;
    settings =
      let
        mkShare =
          {
            name,
            user ? "smb",
            group ? "smb",
            hasBunker ? false,
            hasPaperless ? false,
            persistRoot ? "/panzer",
          }:
          cfg:
          let
            config = {
              "#persistRoot" = persistRoot;
              "#user" = user;
              "#group" = group;
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0740";
              "directory mask" = "0750";
              "force user" = user;
              "force group" = group;
              "valid users" = "${user} @${group}";
              "force create mode" = "0660";
              "force directory mode" = "0770";
              # Might be necessary for windows user to be able to open thing in smb
              "acl allow execute always" = "no";
            } // cfg;
          in
          {
            "${name}" = config // {
              "path" = "/media/smb/${name}";
            };
          }
          // lib.optionalAttrs hasBunker {
            "${name}-important" = config // {
              "path" = "/media/smb/${name}-important";
              "#persistRoot" = "/bunker";
            };
          }
          // lib.optionalAttrs hasPaperless {
            "${name}-paperless" = config // {
              "path" = "/media/smb/${name}-paperless";
              "#paperless" = true;
              "force user" = "paperless";
              "force group" = "paperless";
              # Empty to prevent imperamence setting a persistence folder
              "#persistRoot" = "";
            };
          };
      in
      lib.mkMerge [
        {
          global = {
            logging = "systemd";
            security = "user";
            "log level" = "0 auth:2 passdb:2";
            "passdb backend" = "tdbsam:${config.age.secrets.smbpassdb.path}";
            "server role" = "standalone";
            # Show the server host name in the printer comment box in print manager
            # and next to the IPC connection in net view.
            "server string" = "patricks-tolles-nas";
            # Set the NetBIOS name by which the Samba server is known.
            "netbios name" = "patricks-tolles-nas";
            # Disable netbios support. We don't need to support browsing since all
            # clients hardcode the host and share names.
            "disable netbios" = "yes";
            # Allow access to local network
            "hosts allow" = "10. localhost";

            "guest account" = "nobody";
            "map to guest" = "bad user";

            # Clients should only connect using the latest SMB3 protocol (e.g., on
            # clients running Windows 8 and later).
            "server min protocol" = "SMB3_11";
            # Require native SMB transport encryption by default.
            "server smb encrypt" = "required";
            # Do not map the executable bit to anything
            "map archive" = "no";
            "map system" = "no";
            "map hidden" = "no";

            # Disable printer sharing. By default Samba shares printers configured
            # using CUPS.
            "load printers" = "no";
            "printing" = "bsd";
            "printcap name" = "/dev/null";
            "disable spoolss" = "yes";
            "show add printer wizard" = "no";
          };
        }
        (mkShare {
          name = "ggr-data";
          user = "ggr";
          group = "ggr";
          hasBunker = true;
        } { })
        (mkShare {
          name = "patri";
          user = "patrick";
          group = "patrick";
          hasBunker = true;
          hasPaperless = true;
        } { })
        (mkShare {
          name = "helen-data";
          user = "helen";
          group = "helen";
          hasBunker = true;
        } { })
        (mkShare {
          name = "david";
          user = "david";
          group = "david";
          hasBunker = true;
          hasPaperless = true;
        } { })
        (mkShare {
          name = "printer";
          user = "printer";
          group = "printer";
        } { })
        (mkShare {
          name = "family-data";
          user = "family";
          group = "family";
        } { })
        (mkShare
          {
            name = "media";
            user = "family";
            group = "family";
            persistRoot = "/renaultft";
          }
          {
            "guest ok" = "yes";
            "read only" = "yes";
            "write list" = "@family";
          }
        )
      ];
  };
  # to get this file start a smbd, add users using 'smbpasswd -a <user>'
  # then export the database using 'pdbedit -e tdbsam:<location>'
  age.secrets.smbpassdb = {
    rekeyFile = config.node.secretsDir + "/smbpassdb.tdb.age";
  };
  users =
    let
      users = lib.unique (lib.flatten (lib.mapAttrsToList (_: val: val."force user") shares));
      groups = lib.unique (
        users ++ (lib.flatten (lib.mapAttrsToList (_: val: val."force group") shares))
      );
    in
    {
      users = lib.mkMerge (
        (lib.flip map users (user: {
          ${user} = {
            isNormalUser = true;
            home = "/var/empty";
            createHome = false;
            useDefaultShell = false;
            autoSubUidGidRange = false;
            group = "${user}";
          };
        }))
        ++ [ { paperless.isNormalUser = lib.mkForce false; } ]
      );
      groups = lib.mkMerge (
        (lib.flip map groups (group: {
          ${group} = { };
        }))
        ++ [
          {
            family.members = [
              "patrick"
              "david"
              "helen"
              "ggr"
            ];
            printer.members = [
              "patrick"
              "david"
              "helen"
              "ggr"
            ];
          }
        ]
      );
    };

  fileSystems = lib.mkMerge (
    lib.flip lib.mapAttrsToList shares (
      _: v:
      lib.optionalAttrs ((v ? "#paperless") && v."#paperless") {
        "${v.path}/consume" = {
          fsType = "none";
          options = [ "bind" ];
          device = "/paperless/consume/${v."#user"}";
        };
        "${v.path}/media/archive" = {
          fsType = "none  ";
          options = [
            "bind"
            "ro"
          ];
          device = "/paperless/media/documents/archive/${v."#user"}";
        };
        "${v.path}/media/originals" = {
          fsType = "none  ";
          options = [
            "bind"
            "ro"
          ];
          device = "/paperless/media/documents/originals/${v."#user"}";
        };
      }
    )
  );

  systemd.tmpfiles.settings = lib.mkMerge (
    lib.flip lib.mapAttrsToList shares (
      _: v:
      lib.optionalAttrs ((v ? "#paperless") && v."#paperless") {
        "10-smb-paperless"."/paperless/consume/".d = {
          user = "paperless";
          group = "paperless";
          mode = "0770";
        };
        "10-smb-paperless"."/paperless/consume/${v."#user"}".d = {
          user = "paperless";
          group = "paperless";
          mode = "0770";
        };
        "10-smb-paperless"."/paperless/media/".d = {
          user = "paperless";
          group = "paperless";
          mode = "0770";
        };
        "10-smb-paperless"."/paperless/media/documents/".d = {
          user = "paperless";
          group = "paperless";
          mode = "0770";
        };

        "10-smb-paperless"."/paperless/media/documents/archive/".d = {
          user = "paperless";
          group = "paperless";
          mode = "0770";
        };
        "10-smb-paperless"."/paperless/media/documents/archive/${v."#user"}".d = {
          user = "paperless";
          group = "paperless";
          mode = "0770";
        };
        "10-smb-paperless"."/paperless/media/documents/archive/${v."#user"}/.keep".f = {
          user = "paperless";
          group = "paperless";
          mode = "0660";
        };
        "10-smb-paperless"."/paperless/media/documents/originals/".d = {
          user = "paperless";
          group = "paperless";
          mode = "0770";
        };
        "10-smb-paperless"."/paperless/media/documents/originals/${v."#user"}".d = {
          user = "paperless";
          group = "paperless";
          mode = "0770";
        };
        "10-smb-paperless"."/paperless/media/documents/originals/${v."#user"}/.keep".f = {
          user = "paperless";
          group = "paperless";
          mode = "0660";
        };
      }
    )
  );
  environment.persistence = lib.mkMerge (
    lib.flatten [
      (lib.flip lib.mapAttrsToList shares (
        _: v:
        lib.optionalAttrs ((v ? "#persistRoot") && (v."#persistRoot" != "")) {
          ${v."#persistRoot"}.directories = [
            {
              directory = "${v.path}";
              user = "${v."force user"}";
              group = "${v."force group"}";
              mode = "0770";
            }
          ];
        }
      ))
    ]
  );
}
