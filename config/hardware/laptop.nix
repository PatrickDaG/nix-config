{
  services = {
    logind.extraConfig = ''
      IdleAction=suspend
      IdleActionSec=300
    '';
    physlock = {
      enable = true;
      muteKernelMessages = true;
    };
    tlp = {
      enable = true;
      settings = {
        USB_EXCLUDE_PHONE = 1;
      };
    };
  };
  hardware.acpilight.enable = true;
}
