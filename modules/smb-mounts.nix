{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    any
    mkOption
    types
    flip
    attrNames
    concatMap
    optional
    ;
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

  imports =
    let
      existingCfg = flip any (attrNames config.home-manager.users) (
        user: (config.home-manager.users.${user}.home.smb != [ ])
      );
    in
    [
      {
        environment.systemPackages = lib.optional existingCfg pkgs.cifs-utils;
        systemd.mounts = flip concatMap (attrNames config.home-manager.users) (
          user:
          let
            parentPath = "/home/${user}/smb";
            cfg = config.home-manager.users.${user}.home.smb;
            inherit (config.users.users.${user}) uid;
            inherit (config.users.groups.${user}) gid;
          in
          flip map cfg (cfg: {
            what = "//${cfg.address}/${cfg.remotePath}";
            where = "${parentPath}/${cfg.localPath}";
            type = "cifs";
            options = lib.concatStringsSep "," [
              "uid=${toString uid}"
              "gid=${toString gid}"
              "file_mode=0600"
              "dir_mode=0700"
              "credentials=${cfg.credentials}"
              "_netdev"
            ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            mountConfig.TimeoutSec = "5s";
          })
        );

        systemd.automounts = flip concatMap (attrNames config.home-manager.users) (
          user:
          let
            parentPath = "/home/${user}/smb";
            cfg = config.home-manager.users.${user}.home.smb;
          in
          flip map cfg (cfg: {
            where = "${parentPath}/${cfg.localPath}";
            wantedBy = optional cfg.automatic "remote-fs.target";
            automountConfig.TimeoutIdleSec = 60;
          })
        );

        systemd.tmpfiles.rules = flip concatMap (attrNames config.home-manager.users) (
          user:
          let
            parentPath = "/home/${user}/smb";
            cfg = config.home-manager.users.${user}.home.smb;
            inherit (config.users.users.${user}) uid;
            inherit (config.users.groups.${user}) gid;
          in
          [ "d ${parentPath} 0700 ${toString uid} ${toString gid} -" ]
          ++ flip map cfg (cfg: "d ${parentPath}/${cfg.localPath} 0700 ${toString uid} ${toString gid} -")
        );
      }
    ];
}
