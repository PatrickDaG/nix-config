{lib, ...}: {
  services.xserver.videoDrivers = lib.mkForce ["nvidia"];

  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
    nvidia = {
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      modesetting.enable = true;
    };
  };
}
