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
            (partEfi "boot" "0%" "2GiB")
            #(partSwap "swap" "2GiB" "18GiB")
            (partLuksZfs "m2-ssd" "rpool" "18GiB" "100%")
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
            (partLuksZfs "sata-hdd" "panzer" "0%" "100%")
          ];
        };
      };
    };
    zpool = with lib.disko.zfs; {
      rpool = mkZpool {datasets = impermanenceZfsDatasets;};
      panzer = mkZpool {
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
  boot.initrd.systemd.services."zfs-import-panzer".after = ["cryptsetup.target"];
}
