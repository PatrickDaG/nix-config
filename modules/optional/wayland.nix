{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-wlr];
  };
  environment.systemPackages = with pkgs; [
    xdg-utils
    wdisplays
    wl-clipboard
  ];
}
