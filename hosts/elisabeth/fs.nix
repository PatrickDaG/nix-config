{
  config,
  lib,
  ...
}: {
  disko.devices = {
    disk = {
      internal-ssd = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.nvme}";
        content = with lib.disko.gpt; {
          type = "table";
          format = "gpt";
          partitions = [
            (partEfi "boot" "0%" "1GiB")
            (partLuksZfs "ssd" "rpool" "1GiB" "100%")
          ];
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
      rpool = mkZpool {datasets = impermanenceZfsDatasets;};
      panzer = mkZpool {
        datasets = {
          "safe/guests" = unmountable;
        };
      };
      renaultft = mkZpool {
        datasets = {
          "safe/guests" = unmountable;
        };
      };
    };
  };

  services.zrepl = {
    enable = true;
    settings = {
      global = {
        logging = [
          {
            type = "syslog";
            level = "info";
            format = "human";
          }
        ];
        # TODO Monitoring
      };
      jobs = [
        #{
        #  type = "push";
        #  name = "push-to-remote";
        #}
        {
          type = "snap";
          name = "mach-schnipp-schusss";
          filesystems = {
            "panzer/safe<" = true;
            "rpool/local/state<" = true;
            "rpool/safe<" = true;
            "renaultft/safe<" = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = "zrepl-";
            interval = "10m";
            timestamp_format = "iso-8601";
          };
          pruning = {
            keep = [
              {
                type = "regex";
                regex = "^zrepl-.*$";
                negate = true;
              }
              {
                type = "grid";
                grid = lib.concatStringsSep " | " [
                  "1x1d(keep=all)"
                  "142x1h(keep=2)"
                  "90x1d(keep=2)"
                  "500x7d"
                ];
                regex = "^zrepl-.*$";
              }
            ];
          };
        }
      ];
    };
  };

  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  boot.initrd.systemd.services."zfs-import-panzer".after = ["cryptsetup.target"];
  boot.initrd.systemd.services."zfs-import-renaultft".after = ["cryptsetup.target"];
}
