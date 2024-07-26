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
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common = {
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
