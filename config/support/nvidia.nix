{
  lib,
  config,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = config.programs.steam.enable;
      extraPackages = with pkgs; [
        libva-vdpau-driver
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      open = true;
    };
  };
}
