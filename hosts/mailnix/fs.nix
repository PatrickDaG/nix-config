{ config, lib, ... }:
{
  disko.devices = {
    disk = {
      drive = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.drive}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = (partEfi "256M") // {
              device = "${device}-part1";
            };
            rpool = (partLuksZfs "drive" "rpool" "100%") // {
              device = "${device}-part2";
            };
          };
        };
      };
    };

    zpool = with lib.disko.zfs; {
      rpool = mkZpool { datasets = impermanenceZfsDatasets; };
    };
  };
  snapshots.zfs = true;
}
