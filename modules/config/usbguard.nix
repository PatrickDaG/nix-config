{config, ...}: {
  agenix.secrets.usbguard.rekeyFile = ../../secrets/usbguard.rules.age;
  services.usbguard = {
    rules = builtins.readFile config.age.secrets.usbguard.path;
    enable = true;
  };
}
