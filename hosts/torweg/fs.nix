{ config, lib, ... }:
{
  disko.devices = {
    disk = {
      drive = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.drive}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            grub = partGrub;
            bios = partBoot "512M";
            rpool = partLuksZfs config.secrets.secrets.local.disko.drive "rpool" "100%";
          };
        };
      };
    };

    zpool = with lib.disko.zfs; {
      rpool = mkZpool { datasets = impermanenceZfsDatasets; };
    };
  };

  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  boot.initrd.systemd.services."zfs-import-rpool".after = [ "cryptsetup.target" ];
  boot.loader.grub.devices = [ "/dev/disk/by-id/${config.secrets.secrets.local.disko.drive}" ];

}
