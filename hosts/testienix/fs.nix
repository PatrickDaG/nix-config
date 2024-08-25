{ config, lib, ... }:
{
  disko.devices = {
    disk = {
      internal-hdd = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.internal-hdd}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = partEfi "1G";
            swap = partSwap "16G";
            rpool = lib.attrsets.recursiveUpdate (partLuksZfs "rpool" "rpool" "100%") {
              content.extraFormatArgs = [ "--pbkdf pbkdf2" ];
            };
          };
        };
      };
    };

    zpool = with lib.disko.zfs; {
      rpool = mkZpool { datasets = impermanenceZfsDatasets; };
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
}
