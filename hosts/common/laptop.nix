{pkgs, ...}: {
  services = {
    physlock.enable = true;
    tlp = {
      enable = true;
      # currently broken. Issue open at https://github.com/linrunner/TLP/issues/692
      settings = {
        USB_EXLUDE_PHONE = 1;
      };
    };
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
    '';
  };
}
