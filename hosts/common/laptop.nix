{pkgs, ...}: {
  services = {
    logind.extraConfig = ''
      IdleAction=suspend
      IdleActionSec=300
    '';
    physlock.enable = true;
    tlp = {
      enable = true;
      # currently broken. Issue open at https://github.com/linrunner/TLP/issues/692
      settings = {
        USB_EXCLUDE_PHONE = 1;
      };
    };
    # enabel users in the video group to control backlight
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
    '';
  };
  # enable systemd to save and restore backlight state
  environment.persistence."/state" = {
    directories = [
      "/var/lib/systemd/backlight"
    ];
  };
}
