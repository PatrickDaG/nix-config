{
  config,
  lib,
  ...
}: {
  disko.devices = {
    disk = {
      m2-ssd = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.m2-ssd}";
        content = with lib.disko.gpt; {
          type = "table";
          format = "gpt";
          partitions = [
            (partEfi "boot" "0%" "1GiB")
            (partSwap "swap" "1GiB" "17GiB")
            (partLuksZfs "rpool" "rpool" "17GiB" "100%")
          ];
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
