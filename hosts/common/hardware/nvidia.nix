{lib, ...}: {
  services.xserver.videoDrivers = lib.mkForce ["nvidia"];

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      open = false;
    };
  };
}
