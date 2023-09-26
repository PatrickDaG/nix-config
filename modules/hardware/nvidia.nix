{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  services.xserver.videoDrivers = lib.mkForce ["nvidia"];

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      open = false;
    };
  };
}
