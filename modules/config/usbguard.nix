{config, ...}: {
  age.secrets.usbguard.rekeyFile = ../../secrets/usbguard.rules.age;
  services.usbguard = {
    ruleFile = config.age.secrets.usbguard.path;
    enable = true;
  };
}
