{
  config,
  lib,
  ...
}:
{
  disko.devices = {
    disk = {
      ssd = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.nvme}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = (partEfi "1G") // {
              device = "${device}-part1";
            };
            rpool = (partLuksZfs "ssd" "rpool" "100%") // {
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

  boot.kernel.sysctl."fs.inotify.max_user_instances" = 1024;

  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
}
