inputs: self: super: {
  lib =
    super.lib
    // {
      disko = {
        gpt = {
          partEfiBoot = name: start: end: {
            inherit name start end;
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          partSwap = name: start: end: {
            inherit name start end;
            fs-type = "linux-swap";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
          partLuksZfs = name: pool: start: end: {
            inherit start end;
            name = "enc-${name}";
            content = {
              type = "luks";
              name = "enc-${name}";
              extraOpenArgs = ["--allow-discards"];
              content = {
                type = "zfs";
                inherit pool;
              };
            };
          };
        };
        zfs = rec {
          defaultZpoolOptions = {
            type = "zpool";
            rootFsOptions = {
              compression = "zstd";
              acltype = "posix";
              atime = "off";
              xattr = "sa";
              dnodesize = "auto";
              mountpoint = "none";
              canmount = "off";
              devices = "off";
            };
            options.ashift = "12";
          };
          defaultZfsDatasets = {
            "local" = unmountable;
            "local/root" =
              filesystem "/"
              // {
                postCreateHook = "zfs snapshot rpool/local/root@blank";
              };
            "local/nix" = filesystem "/nix";
            "local/state" = filesystem "/state";
            "safe" = unmountable;
            "safe/persist" = filesystem "/persist";
          };
          unmountable = {type = "zfs_fs";};
          filesystem = mountpoint: {
            type = "zfs_fs";
            options = {
              canmount = "noauto";
              inherit mountpoint;
            };
            inherit mountpoint;
            # needed for initrd dependency
          };
        };
      };
    };
}
