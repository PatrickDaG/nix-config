# Configuration for actual physical machines
{
  config,
  minimal,
  ...
}:
{
  # Should be minima because it's quite large(~700 MB)
  # Should not be minimal because then you have missing firmware on reboot
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  services = {
    # Enable if you're feeling very fwupd that day
    #fwupd.enable = !minimal;
    smartd.enable = !minimal;
    thermald.enable = builtins.elem config.nixpkgs.hostPlatform.system [ "x86_64-linux" ];
  };
}
