{
  fileSystems."/" = {
    device = "rpool/ROOT/nixos";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BC47-8FB9";
    fsType = "vfat";
  };

  swapDevices = [];
}
