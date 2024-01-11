{
  config,
  lib,
  ...
}: {
  disko.devices = {
    disk = {
      drive = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.drive}";
        content = with lib.disko.gpt; {
          type = "table";
          format = "gpt";
          partitions = [
            (partGrub "grub" "0%" "1MiB")
            (partEfi "bios" "1MiB" "512MiB")
            (partLuksZfs "rpool" "rpool" "512MiB" "100%")
            #(lib.attrsets.recursiveUpdate (partLuksZfs "rpool" "rpool" "17GiB" "100%") {content.extraFormatArgs = ["--pbkdf pbkdf2"];})
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
  boot.initrd.luks.devices.enc-rpool.allowDiscards = true;
  boot.loader.grub.devices = [
    "/dev/disk/by-id/${config.secrets.secrets.local.disko.drive}"
  ];
}
