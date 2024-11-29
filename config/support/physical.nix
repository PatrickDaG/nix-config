# Configuration for actual physical machines
{
  config,
  minimal,
  lib,
  ...
}:
{
  hardware = lib.mkIf (!minimal) {
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
