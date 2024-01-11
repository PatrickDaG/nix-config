{
  config,
  lib,
  ...
}: {
  disko.devices = {
    disk = {
      ssd = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.ssd}";
        content = with lib.disko.gpt; {
          type = "table";
          format = "gpt";
          partitions = [
            (partEfi "boot" "0%" "260MB")
            {
              name = "rpool";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            }
          ];
        };
      };
    };
    zpool = with lib.disko.zfs; {
      rpool = mkZpool {datasets = impermanenceZfsDatasets;};
    };
  };
  fileSystems."/state".neededForBoot = true;
}
