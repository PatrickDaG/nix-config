{
  services = {
    logind.settings.Login = {
      LidSwitch = "ignore";
      LidSwitchDocked = "ignore";
      LidSwitchExternalPower = "ignore";
      HandlePowerKey = "suspend";
      HandleSuspendKey = "suspend";
      HandleHibernateKey = "suspend";
      PowerKeyIgnoreInhibited = "yes";
      SuspendKeyIgnoreInhibited = "yes";
      HibernateKeyIgnoreInhibited = "yes";
    };
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
