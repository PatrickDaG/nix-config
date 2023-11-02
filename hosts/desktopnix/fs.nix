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
            (partEfiBoot "boot" "0%" "2GiB")
            (partSwap "swap" "2GiB" "18GiB")
            (partLuksZfs "rpool" "rpool" "18GiB" "100%")
          ];
        };
      };
      sata-hdd = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.sata-hdd}";
        content = with lib.disko.gpt; {
          type = "table";
          format = "gpt";
          partitions = [
            (partLuksZfs "panzer" "panzer" "0%" "100%")
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
            "local" = unmountable;
            "local/state" = filesystem "/panzer/state";
          };
        };
    };
  };
  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/panzer/state".neededForBoot = true;
  boot.initrd.luks.devices.enc-rpool.allowDiscards = true;
  boot.initrd.luks.devices.enc-panzer.allowDiscards = true;
}
