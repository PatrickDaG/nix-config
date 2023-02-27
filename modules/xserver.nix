{
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    layout = "de";
    xkbVariant = "bone";
    autoRepeatDelay = 235;
    autoRepeatInterval = 60;
    videoDrivers = ["modesetting"];
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad = {
        accelProfile = "flat";
        accelSpeed = "0.5";
        naturalScrolling = true;
        disableWhileTyping = true;
      };
    };
  };
  services.autorandr.enable = true;
  services.physlock.enable = true;
}
