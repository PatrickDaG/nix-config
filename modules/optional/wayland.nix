{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  services.dbus.enable = true;
  environment.systemPackages = with pkgs; [
    xdg-utils
    wdisplays
    wl-clipboard
  ];
}
