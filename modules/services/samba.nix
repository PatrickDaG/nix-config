{
  config,
  lib,
  ...
}: {
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = lib.concatLines [
      ''
        logging = systemd
        log level = 0 auth:2 passdb:2
        passdb backend = tdbsam:${config.age.secrets.smbpassdb.path}
        server role = standalone
      ''
      # Show the server host name in the printer comment box in print manager
      # and next to the IPC connection in net view.
      "server string = patricks-tolles-nas"
      # Set the NetBIOS name by which the Samba server is known.
      "netbios name = my-nas"
      # Disable netbios support. We don't need to support browsing since all
      # clients hardcode the host and share names.
      "disable netbios = yes"
      # Deny access to all hosts by default.
      "hosts deny = 0.0.0.0/0"
      # Allow access to local network
      "hosts allow = 192.168.178. 127.0.0.1 10.0.0. localhost"

      "guest account = nobody"
      "map to guest = bad user"

      # Clients should only connect using the latest SMB3 protocol (e.g., on
      # clients running Windows 8 and later).
      "server min protocol = SMB3_11"
      # Require native SMB transport encryption by default.
      "server smb encrypt = required"

      # Disable printer sharing. By default Samba shares printers configured
      # using CUPS.
      "load printers = no"
      "printing = bsd"
      "printcap name = /dev/null"
      "disable spoolss = yes"
      "show add printer wizard = no"
    ];
    shares = let
      mkShare = {
        name,
        user ? "smb",
        group ? "smb",
      }: cfg: {
        "${name}" =
          {
            "path" = "/media/smb/${name}";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0640";
            "directory mask" = "0750";
            "force user" = "${user}";
            "force group" = "${group}";
            "valid users" = "${user} @${group}";
            "force create mode" = "0660";
            "force directory mode" = "0770";
            # Might be necessary for windows user to be able to open thing in smb
            "acl allow execute always" = "no";
          }
          // cfg;
      };
    in
      lib.mkMerge [
        (mkShare {
          name = "ggr-data";
          user = "ggr";
          group = "ggr";
        } {})
        (mkShare {
          name = "patri-data";
          user = "patrick";
          group = "patrick";
        } {})
        ((mkShare {name = "media";})
          {
            "read only" = "yes";
            "write list" = "smb";
          })
      ];
  };
  # to get this file start a smbd add users using 'smbpasswd -a <user>'
  # then export the database using 'pdbedit -e tdbsam:<location>'
  age.secrets.smbpassdb = {
    rekeyFile = ../../secrets/smbpassdb.tdb.age;
  };
  users = let
    users = lib.unique (lib.mapAttrsToList (_: val: val."force user") config.services.samba.shares);
    groups = lib.unique (users ++ (lib.mapAttrsToList (_: val: val."force group") config.services.samba.shares));
  in {
    users = lib.mkMerge (lib.flip map users (user: {
        ${user} = {
          isNormalUser = true;
          home = "/var/empty";
          createHome = false;
          useDefaultShell = false;
          autoSubUidGidRange = false;
          group = "${user}";
        };
      })
      ++ [
        {
          patrick.extraGroups = [
            "family"
          ];
          ggr.extraGroups = [
            "family"
          ];
        }
      ]);
    groups = lib.mkMerge (lib.flip map groups (group: {
      ${group} = {
      };
    }));
  };

  environment.persistence."/panzer/persist".directories = lib.flip lib.mapAttrsToList config.services.samba.shares (_: v: {
    directory = "${v.path}";
    user = "${v."force user"}";
    group = "${v."force group"}";
    mode = "0770";
  });
}
