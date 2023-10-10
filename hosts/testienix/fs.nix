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
            (lib.attrsets.recursiveUpdate (partLuksZfs "rpool" "rpool" "17GiB" "100%") {content.extraFormatArgs = ["--pbkdf pbkdf2"];})
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
            (lib.attrsets.recursiveUpdate (partLuksZfs "panzer-1" "panzer" "0%" "100%") {content.extraFormatArgs = ["--pbkdf pbkdf2"];})
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
            (lib.attrsets.recursiveUpdate (partLuksZfs "panzer-2" "panzer" "0%" "100%") {content.extraFormatArgs = ["--pbkdf pbkdf2"];})
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
            "safe" = unmountable;
            "safe/data" = filesystem "/data";
          };
        };
    };
  };

  boot.initrd.luks.devices.enc-rpool.allowDiscards = true;
}
