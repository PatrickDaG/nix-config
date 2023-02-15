{
  lib,
  pkgs,
  ...
}: {
  services.xserver.videoDrivers = lib.mkForce ["nvidia"];

  hardware.nvidia = {
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    modesetting.enable = true;
    prime = {
      offload = {
        enableOffloadCmd = true;
        enable = true;
      };

      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:59:00:0";
    };
  };
}
