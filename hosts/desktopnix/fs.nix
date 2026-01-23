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
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.m2-ssd}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = (partEfi "2GiB") // {
              device = "${device}-part1";
            };
            swap = (partSwap "16G") // {
              device = "${device}-part2";
            };
            rpool = (partLuksZfs "m2-ssd" "rpool" "100%") // {
              device = "${device}-part3";
            };
          };
        };
      };
      sata-hdd = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.sata-hdd}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            panzer = (partLuksZfs "sata-hdd" "panzer" "100%") // {
              device = "${device}-part1";
            };
          };
        };
      };
    };
    zpool = with lib.disko.zfs; {
      rpool = mkZpool {
        datasets = impermanenceZfsDatasets // {
          "local/tmp" = lib.recursiveUpdate (filesystem "/tmp") {
            options = {
              sync = "disabled";
            };
          };
        };
      };
      panzer = mkZpool {
        datasets = {
          "local" = unmountable;
          "local/state" = filesystem "/panzer/state";
        };
      };
    };
  };

  fileSystems."/panzer/state".neededForBoot = true;
  boot.initrd.systemd.services."zfs-import-panzer".after = [ "cryptsetup.target" ];
  boot.initrd.systemd.services."zfs-import-rpool".after = [ "cryptsetup.target" ];

  systemIdentity = {
    enable = true;
    pcr15 = "dc9b7fa0d2a0ef5441bb8bfb7b2103b9f45f1143d87f69929c12cf7a3cc35ccf";
  };
  boot.tmp.useTmpfs = lib.mkForce false;
}
