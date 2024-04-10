{
  config,
  lib,
  ...
}: {
  disko.devices = {
    disk = {
      m2-ssd = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.m2-ssd}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = (partEfi "1GiB") // {device = "${device}-part1";};
            swap = (partSwap "16GiB") // {device = "${device}-part2";};
            rpool = (partLuksZfs "rpool" "rpool" "100%") // {device = "${device}-part3";};
          };
        };
      };
    };
    zpool = with lib.disko.zfs; {
      rpool = mkZpool {datasets = impermanenceZfsDatasets;};
    };
  };
  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
}
