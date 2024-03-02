{
  config,
  lib,
  ...
}: {
  disko.devices = {
    disk = {
      drive = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.drive}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            grub = (partGrub "0%" "1MiB") // {device = "${device}-part1";};
            bios = (partEfi "1MiB" "512MiB") // {device = "${device}-part2";};
            "rpool_rpool" = (partLuksZfs "rpool" "rpool" "512MiB" "100%") // {device = "${device}-part3";};
            #(lib.attrsets.recursiveUpdate (partLuksZfs "rpool" "rpool" "17GiB" "100%") {content.extraFormatArgs = ["--pbkdf pbkdf2"];})
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
  boot.loader.grub.devices = [
    "/dev/disk/by-id/${config.secrets.secrets.local.disko.drive}"
  ];
}
