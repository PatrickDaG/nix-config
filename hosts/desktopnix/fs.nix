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
            (partEfiBoot "boot" "0%" "1GiB")
            (partSwap "swap" "1GiB" "17GiB")
            (partLuksZfs "rpool" "rpool" "17GiB" "100%")
          ];
        };
      };
      sata-ssd = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.sata-ssd}";
        content = with lib.disko.gpt; {
          type = "table";
          format = "gpt";
          partitions = [
            (partLuksZfs "infantry-fighting-vehicle" "infantry-fighting-vehicle" "0%" "100%")
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
      infantry-fighting-vehicle = defaultZpoolOptions // {datasets = {};};
      panzer = defaultZpoolOptions // {datasets = {};};
    };
  };
  boot.initrd.luks.devices.enc-rpool.allowDiscards = true;
  boot.initrd.luks.devices.enc-infantry-fighting-vehicle.allowDiscards = true;
}