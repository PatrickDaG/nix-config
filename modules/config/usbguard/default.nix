{
  services.usbguard = {
    rules = builtins.readFile ./rules.rules;
    enable = true;
  };
}
