{
  config,
  lib,
  ...
}: {
  disko.devices = {
    disk = {
      internal-hdd = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.internal-hdd}";
        content = with lib.disko.gpt; {
          type = "table";
          format = "gpt";
          partitions = [
            (partEfiBoot "boot" "0%" "1GiB")
            (partSwap "swap" "1GiB" "17GiB")
            (partLuksZfs "rpool" "rpool" "17GiB" "100%")
          ];
        };
      };
      external-hdd-1 = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.external-hdd-1}";
        content = with lib.disko.gpt; {
          type = "table";
          format = "gpt";
          partitions = [
            (partLuksZfs "panzer-1" "panzer" "0%" "100%")
          ];
        };
      };
      external-hdd-2 = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.external-hdd-2}";
        content = with lib.disko.gpt; {
          type = "table";
          format = "gpt";
          partitions = [
            (partLuksZfs "panzer-2" "panzer" "0%" "100%")
          ];
        };
      };
    };

    zpool = with lib.disko.zfs; {
      rpool = defaultZpoolOptions // {datasets = defaultZfsDatasets;};
      panzer =
        defaultZpoolOptions
        // {
          datasets = {
            "save" = unmountable;
            "safe/data" = filesystem "/data";
          };
        };
    };
  };
}
