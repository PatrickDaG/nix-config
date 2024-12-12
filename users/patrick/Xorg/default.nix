{
  pkgs,
  lib,
  minimal,
  config,
  ...
}:
lib.optionalAttrs (!minimal) {
  hm.home.packages = [
    pkgs.xclip
    pkgs.xdragon
  ];
  imports = [
    ./rofi.nix
    ./i3.nix
  ];
  #xsession.wallpapers.enable = true;
  hm.home.file.".xinitrc".source = ./xinitrc;

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    autoRepeatDelay = 235;
    autoRepeatInterval = 60;
    videoDrivers = [ "modesetting" ];
  };
  services.libinput = {
    enable = true;
    mouse = {
      accelSpeed = "0.3";
      accelProfile = "flat";
      middleEmulation = false;
    };
    touchpad = {
      accelProfile = "flat";
      accelSpeed = "1";
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };
  services.udev.extraRules =
    let
      exe = pkgs.writeShellScript "set-key-repeat" ''
        if [ -d "/tmp/.X11-unix" ]; then
        	for D in /tmp/.X11-unix/*; do
        	file=$(${pkgs.coreutils}/bin/basename $D)
        	export DISPLAY=":''${file:1}"
        	user=$(${pkgs.coreutils}/bin/stat -c '%U' "$D")
        	# sleep to give X time to access the keyboard
        	(sleep 0.2; ${pkgs.util-linux}/bin/runuser -u "$user" -- ${pkgs.xorg.xset}/bin/xset r rate \
        	${toString config.services.xserver.autoRepeatDelay} ${toString config.services.xserver.autoRepeatInterval})&
        	done
        fi
      '';
    in
    ''
      ACTION=="add", SUBSYSTEM=="input", ATTRS{bInterfaceClass}=="03", RUN+="${exe}"
    '';
}
