{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    flip
    attrNames
    toString
    flatten
    ;
  baseOptions = [
    "x-systemd.idle-timeout=60"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
  ];
in {
  # Give users the ability to add their own smb shares
  home-manager.sharedModules = [
    {
      options.home.smb = mkOption {
        description = "Samba shares to be mountable under $HOME/smb";
        default = {};
        type = types.listOf types.submodule {
          options = {
            localPath = mkOption {
              description = "The path under which the share will be mounted. Defaults to the remotePath";
              type = types.str;
              default = null;
            };
            address = mkOption {
              description = "The remote share address";
              type = types.str;
              example = "10.1.2.5";
            };
            remotePath = mkOption {
              description = "The remote share path";
              type = types.str;
              example = "data-10";
            };
            credentials = mkOption {
              description = "A smb credential file to access the remote share";
              type = types.path;
            };
            automatic = mkOption {
              description = "Whether this share should be automatically mounted on boot";
              default = false;
              type = types.boolean;
            };
          };
        };
      };
    }
  ];

  imports = flatten (
    flip
    map
    (attrNames config.home-manager.users)
    (
      user: let
        parentPath = "${config.home-manager.users.${user}.homeDir}/smb";
        cfg = config.home-manager.users.user.smb;
      in
        flip map cfg (
          cfg: {
            environment.systemPackages = [pkgs.cifs-utils];
            fileSystems = {
              "${parentPath}/${cfg.localpath or cfg.remotePath}" = let
                options =
                  baseOptions
                  ++ [
                    "uid=${toString config.users.users.${user}.uid}"
                    "gid=${toString config.users.groups.${user}.gid}"
                    "credentials=${cfg.credentials}"
                    "${
                      if cfg.automatic
                      then ""
                      else "noauto"
                    }"
                  ];
              in {
                inherit options;
                device = "//${cfg.address}/${cfg.remotePath}";
                fsType = "cifs";
              };
            };
          }
        )
    )
  );
}
