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
            (partEfiBoot "boot" "0%" "512MiB")
            #(partSwap "swap" "1GiB" "17GiB")
            (partLuksZfs "rpool" "rpool" "512MiB" "100%")
          ];
        };
      };
    };
    zpool = with lib.disko.zfs; {
      rpool = defaultZpoolOptions // {datasets = defaultZfsDatasets;};
    };
  };
}
