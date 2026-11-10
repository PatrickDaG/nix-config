# Configuration for actual physical machines
{
  config,
  lib,
  minimal,
  ...
}:
{
  # Keep full hardware support unless a host explicitly selects a smaller firmware set.
  hardware = {
    enableRedistributableFirmware = lib.mkDefault true;
    enableAllFirmware = lib.mkDefault true;
  };

  security.tpm2.enable = true;

  services = {
    # Enable if you're feeling very fwupd that day
    #fwupd.enable = !minimal;
    smartd.enable = !minimal;
    thermald.enable = builtins.elem config.nixpkgs.hostPlatform.system [ "x86_64-linux" ];
  };
}
