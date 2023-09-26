{
  lib,
  minimal,
  ...
}:
lib.optionalAttrs (!minimal) {
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    autoRepeatDelay = 235;
    autoRepeatInterval = 60;
    videoDrivers = ["modesetting"];
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad = {
        accelProfile = "flat";
        accelSpeed = "1";
        naturalScrolling = true;
        disableWhileTyping = true;
      };
    };
  };
  services.autorandr.enable = true;
}
