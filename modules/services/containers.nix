{
  config,
  lib,
  utils,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mapAttrsToList
    flip
    types
    mkOption
    mkEnableOption
    mdDoc
    mkIf
    disko
    makeBinPath
    escapeShellArg
    mkMerge
    ;
in {
  options.containers = mkOption {
    type = types.attrsOf (types.submodule (
      {name, ...}: {
        options = {
          zfs = {
            enable = mkEnableOption (mdDoc "persistent data on separate zfs dataset");

            pool = mkOption {
              type = types.str;
              description = mdDoc "The host's zfs pool on which the dataset resides";
            };

            dataset = mkOption {
              type = types.str;
              default = "safe/containers/${name}";
              description = mdDoc "The host's dataset that should be used for this containers persistent data (will automatically be created, parent dataset must exist)";
            };

            mountpoint = mkOption {
              type = types.str;
              description = mdDoc "The host's mountpoint for the containers dataset";
            };
          };
        };
      }
    ));
  };
  config.disko = mkMerge (flip mapAttrsToList config.containers
    (
      _: cfg: {
        devices.zpool = mkIf cfg.zfs.enable {
          ${cfg.zfs.pool}.datasets."${cfg.zfs.dataset}" =
            disko.zfs.filesystem cfg.zfs.mountpoint;
        };

        # Ensure that the zfs dataset exists before it is mounted.
      }
    ));
  config.systemd = mkMerge (flip mapAttrsToList config.containers
    (
      name: cfg: {
        services = let
          fsMountUnit = "${utils.escapeSystemdPath cfg.zfs.mountpoint}.mount";
        in
          mkIf cfg.zfs.enable {
            # Ensure that the zfs dataset exists before it is mounted.
            "zfs-ensure-${utils.escapeSystemdPath cfg.zfs.mountpoint}" = {
              wantedBy = [fsMountUnit];
              before = [fsMountUnit];
              after = [
                "zfs-import-${utils.escapeSystemdPath cfg.zfs.pool}.service"
                "zfs-mount.target"
              ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = let
                poolDataset = "${cfg.zfs.pool}/${cfg.zfs.dataset}";
                diskoDataset = config.disko.devices.zpool.${cfg.zfs.pool}.datasets.${cfg.zfs.dataset};
              in ''
                export PATH=${makeBinPath [pkgs.zfs]}":$PATH"
                if ! zfs list -H -o type ${escapeShellArg poolDataset} &>/dev/null ; then
                  ${diskoDataset._create}
                fi
              '';
            };

            # Ensure that the zfs dataset has the correct permissions when mounted
            "zfs-chown-${utils.escapeSystemdPath cfg.zfs.mountpoint}" = {
              after = [fsMountUnit];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = ''
                chmod 700 ${escapeShellArg cfg.zfs.mountpoint}
              '';
            };

            "container@${name}" = {
              requires = [fsMountUnit "zfs-chown-${utils.escapeSystemdPath cfg.zfs.mountpoint}.service"];
              after = [fsMountUnit "zfs-chown-${utils.escapeSystemdPath cfg.zfs.mountpoint}.service"];
            };
          };
      }
    ));
}
