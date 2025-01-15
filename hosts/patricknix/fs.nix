{
  config,
  lib,
  pkgs,
  ...
}:
{

  disko.devices = {
    disk = {
      m2-ssd = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.m2-ssd}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = (partEfi "1GiB") // {
              device = "${device}-part1";
            };
            swap = (partSwap "16GiB") // {
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
  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  boot.initrd.systemd.extraBin = {
    jq = lib.getExe pkgs.jq;
  };
  systemIdentity = {
    enable = true;
    pcr15 = "6214de8c3d861c4b451acc8c4e24294c95d55bcec516bbf15c077ca3bffb6547";
  };
}
