{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  services.dbus.enable = true;
  environment.systemPackages = with pkgs; [
    wdisplays
    wl-clipboard
  ];
}
