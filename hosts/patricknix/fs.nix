{pkgs, ...}: {
  fileSystems."/" = {
    device = "rpool/local/root";
    neededForBoot = true;
    fsType = "zfs";
    options = ["zfsutil" "X-mount.mkdir"];
  };

  fileSystems."/nix" = {
    device = "rpool/local/nix";
    neededForBoot = true;
    fsType = "zfs";
    options = ["zfsutil" "X-mount.mkdir"];
  };

  fileSystems."/persist" = {
    device = "rpool/safe/persist";
    neededForBoot = true;
    fsType = "zfs";
    options = ["zfsutil" "X-mount.mkdir"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BC47-8FB9";
    fsType = "vfat";
  };

  # After importing the rpool, rollback the root system to be empty.
  boot.initrd.systemd.services.impermanence-root = {
    wantedBy = ["initrd.target"];
    after = ["zfs-import-rpool.service"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.zfs}/bin/zfs rollback -r rpool/local/root@blank";
    };
  };

  swapDevices = [];
}
