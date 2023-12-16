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
            "local" = unmountable;
            "local/state" = filesystem "/panzer/state";
            "safe" = unmountable;
            "safe/persist" = filesystem "/panzer/persist";
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
            "panzer/local/state<" = true;
            "panzer/safe<" = true;
            "rpool/local/state<" = true;
            "rpool/safe<" = true;
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
  fileSystems."/panzer/state".neededForBoot = true;
  fileSystems."/panzer/persist".neededForBoot = true;
  boot.initrd.luks.devices.enc-rpool.allowDiscards = true;
  boot.initrd.luks.devices.enc-panzer-1.allowDiscards = true;
  boot.initrd.luks.devices.enc-panzer-2.allowDiscards = true;
}
