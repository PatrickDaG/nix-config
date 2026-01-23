{
  config,
  lib,
  ...
}:
{

  disko.devices = {
    disk = {
      m2-ssd = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.ssd}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = (partEfi "1G") // {
              device = "${device}-part1";
            };
            swap = (partSwap "32G") // {
              device = "${device}-part2";
            };
            rpool = (partLuksZfs "rpool" "rpool" "100%") // {
              device = "${device}-part3";
            };
          };
        };
      };
    };
    zpool = with lib.disko.zfs; {
      rpool = mkZpool { datasets = impermanenceZfsDatasets; };
    };
  };
  systemIdentity = {
    enable = false;
    pcr15 = "";
  };
}
