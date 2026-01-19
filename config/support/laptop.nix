{
  services = {
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "poweroff";
      HandleSuspendKey = "suspend";
      HandleHibernateKey = "hibernate";
      PowerKeyIgnoreInhibited = "yes";
      SuspendKeyIgnoreInhibited = "yes";
      HibernateKeyIgnoreInhibited = "yes";
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
