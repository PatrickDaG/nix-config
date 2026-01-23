{
  config,
  lib,
  # globals,
  ...
}:
{
  snapshots.zfs = true;
  disko.devices = {
    disk = {
      internal-ssd = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.nvme}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = (partEfi "1GiB") // {
              device = "${device}-part1";
            };
            rpool = (partLuksZfs "ssd" "rpool" "100%") // {
              device = "${device}-part2";
            };
          };
        };
      };
      "4TB-hdd-1" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."4TB-1"}";
        content = lib.disko.content.luksZfs "hdd-4TB-1" "renaultft";
      };
      "4TB-hdd-2" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."4TB-2"}";
        content = lib.disko.content.luksZfs "hdd-4TB-2" "renaultft";
      };
      "4TB-hdd-3" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."4TB-3"}";
        content = lib.disko.content.luksZfs "hdd-4TB-3" "renaultft";
      };
      "8TB-hdd-1" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."8TB-1"}";
        content = lib.disko.content.luksZfs "hdd-8TB-1" "panzer";
      };
      "8TB-hdd-2" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."8TB-2"}";
        content = lib.disko.content.luksZfs "hdd-8TB-2" "panzer";
      };
      "8TB-hdd-3" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."8TB-3"}";
        content = lib.disko.content.luksZfs "hdd-8TB-3" "panzer";
      };
    };

    zpool = with lib.disko.zfs; {
      rpool = mkZpool { datasets = impermanenceZfsDatasets; };
      panzer = mkZpool {
        datasets = {
          "safe/guests" = unmountable;
        };
        mode = "raidz";
      };
      renaultft = mkZpool {
        datasets = {
          "safe/guests" = unmountable;
        };
        mode = "raidz";
      };
    };
  };

  boot.kernel.sysctl."fs.inotify.max_user_instances" = 1024;

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/influxdb2";
      mode = "0700";
      user = "influxdb2";
    }
  ];

  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  boot.initrd.systemd.services."zfs-import-panzer".after = [ "cryptsetup.target" ];
  boot.initrd.systemd.services."zfs-import-renaultft".after = [ "cryptsetup.target" ];
  systemIdentity = {
    enable = true;
  };
}
