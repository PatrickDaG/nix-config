{
  config,
  nodes,
  lib,
  ...
}: {
  disko.devices = {
    disk = {
      m2-ssd = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.m2-ssd}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = (partEfi "0%" "2GiB") // {device = "${device}-part1";};
            swap = (partSwap "2GiB" "18GiB") // {device = "${device}-part2";};
            "rpool_m2-ssd" = (partLuksZfs "m2-ssd" "rpool" "18GiB" "100%") // {device = "${device}-part3";};
          };
        };
      };
      sata-hdd = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.sata-hdd}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            "panzer_sata-hdd" = (partLuksZfs "sata-hdd" "panzer" "0%" "100%") // {device = "${device}-part1";};
          };
        };
      };
    };
    zpool = with lib.disko.zfs; {
      rpool = mkZpool {datasets = impermanenceZfsDatasets;};
      panzer = mkZpool {
        datasets = {
          "local" = unmountable;
          "local/state" = filesystem "/panzer/state";
        };
      };
    };
  };
  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/panzer/state".neededForBoot = true;
  boot.initrd.systemd.services."zfs-import-panzer".after = ["cryptsetup.target"];
  boot.initrd.systemd.services."zfs-import-rpool".after = ["cryptsetup.target"];

  wireguard.scrtiny-patrick.client.via = "elisabeth";

  services.scrutiny = {
    collector = {
      enable = true;
      settings = {
        host.id = "desktopnix";
        api.endpoint = "http://${nodes.elisabeth.config.wireguard.scrtiny-patrick.ipv4}:8080";
      };
    };
  };
}
