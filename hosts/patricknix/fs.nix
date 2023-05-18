{
  fileSystems."/" = {
    device = "rpool/ROOT/nixos";
    fsType = "zfs";
    options = ["zfsutil" "X-mount.mkdir"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BC47-8FB9";
    fsType = "vfat";
  };

  swapDevices = [];
}
