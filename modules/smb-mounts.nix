{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    flip
    attrNames
    mkMerge
    concatMap
    optional
    ;
  baseOptions = [
    "x-systemd.idle-timeout=60"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
  ];
in
{
  # Give users the ability to add their own smb shares
  home-manager.sharedModules = [
    {
      options.home.smb = mkOption {
        description = "Samba shares to be mountable under $HOME/smb";
        default = [ ];
        type = types.listOf (
          types.submodule (
            { config, ... }:
            {
              options = {
                localPath = mkOption {
                  description = "The path under which the share will be mounted. Defaults to the remotePath";
                  type = types.str;
                  default = config.remotePath;
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
                  type = types.bool;
                };
              };
            }
          )
        );
      };
    }
  ];

  imports = [
    {
      environment.systemPackages = [ pkgs.cifs-utils ];
      fileSystems = mkMerge (
        flip concatMap (attrNames config.home-manager.users) (
          user:
          let
            parentPath = "/home/${user}/smb";
            cfg = config.home-manager.users.${user}.home.smb;
            inherit (config.users.users.${user}) uid;
            inherit (config.users.groups.${user}) gid;
          in
          flip map cfg (cfg: {
            "${parentPath}/${cfg.localPath}" =
              let
                options =
                  baseOptions
                  ++ [
                    "uid=${toString uid}"
                    "gid=${toString gid}"
                    "file_mode=0600"
                    "dir_mode=0700"
                    "credentials=${cfg.credentials}"
                    "x-systemd.automount"
                    "_netdev"
                  ]
                  ++ (optional (!cfg.automatic) "noauto");
              in
              {
                inherit options;
                device = "//${cfg.address}/${cfg.remotePath}";
                fsType = "cifs";
              };
          })
        )
      );
    }
  ];
}
