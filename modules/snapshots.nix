{ lib, config, ... }:
let
  cfg = config.snapshots.zfs;
  filteredDatasets = lib.filter (
    x:
    let
      parts = lib.splitString "/" x;
      zpool = lib.elemAt parts 0;
      dataset = lib.concatStringsSep "/" (lib.tail parts);
    in
    # pool has to exists
    (config.disko.devices.zpool ? ${zpool})
    # optional dataset also has to exits
    && ((lib.length parts == 1) || (config.disko.devices.zpool.${zpool}.datasets ? ${dataset}))
  );
  stateDatasets = [
    "rpool/local/state<"
    "rpool/local/guests<"
  ];
  dataDatasets = [
    "panzer<"
    "renaultft<"
    "rpool/safe<"
  ];
  datasets = dataDatasets ++ stateDatasets;
in
{
  options.snapshots.zfs = lib.mkOption {
    type = lib.types.bool;
    default = config.disko.devices.zpool != { };
    description = ''
      Whether to enable automatic snapshotting of zfs datasets
      Will use the default dataset naming as defined in lib.disko.zfs.impermanenceZfsDatasets
    '';
  };
  config = lib.mkIf (cfg && (filteredDatasets datasets) != [ ]) {
    services.zrepl = {
      enable = true;
      settings = {
        global = {
          logging = [
            {
              type = "syslog";
              level = "info";
              format = "human";
            }
          ];
          # TODO Monitoring
        };
        jobs = [
          # short term data
          {
            type = "snap";
            name = "mach-schnipp-schusss-state";
            filesystems = lib.genAttrs (filteredDatasets stateDatasets) (_: true);
            snapshotting = {
              type = "periodic";
              prefix = "zrepl-short";
              interval = "10m";
              timestamp_format = "iso-8601";
            };
            pruning.keep = [
              # Keep all manual snapshots
              {
                type = "regex";
                regex = "^zrepl-.*$";
                negate = true;
              }
              # Keep last n snapshots
              {
                type = "last_n";
                regex = "^zrepl-short-.*$";
                count = 10;
              }
              # Periodic pruning
              {
                type = "grid";
                grid = lib.concatStringsSep " | " [
                  # Keep all snapshots for at least 1 day
                  "1x1d(keep=all)"
                  # For the next 6 days keep 2 snapshost per hour
                  "144x1h(keep=2)"
                  # For the next 3 months keep 2 snapshost per day
                  "90x1d(keep=2)"
                ];
                # Only prune our own snapshots
                regex = "^zrepl-short-.*$";
              }
            ];
          }
          # long-term-data
          {
            type = "snap";
            name = "mach-schnipp-schusss-data";
            filesystems = lib.genAttrs (filteredDatasets dataDatasets) (_: true);
            snapshotting = {
              type = "periodic";
              prefix = "zrepl-long-";
              interval = "10m";
              timestamp_format = "iso-8601";
            };
            pruning.keep = [
              # Keep all manual snapshots
              {
                type = "regex";
                regex = "^zrepl-.*$";
                negate = true;
              }
              # Keep last n snapshots
              {
                type = "last_n";
                regex = "^zrepl-long-.*$";
                count = 10;
              }
              # Periodic pruning
              {
                type = "grid";
                grid = lib.concatStringsSep " | " [
                  # Keep all snapshots for at least 1 day
                  "1x1d(keep=all)"
                  # For the next 6 days keep 2 snapshost per hour
                  "144x1h(keep=2)"
                  # For the next 3 months keep 2 snapshost per day
                  "90x1d(keep=2)"
                  # Indefinitely keep 1 snapshot per week
                  "5000x7d"
                ];
                # Only prune our own snapshots
                regex = "^zrepl-long.*$";
              }
            ];
          }
        ];
      };
    };
  };
}
