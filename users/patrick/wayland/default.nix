{
  lib,
  pkgs,
  ...
}:
{
  services.dbus = {
    enable = true;
    implementation = "broker";
  };
  xdg.portal.enable = true;
  services.gnome.gnome-keyring.enable = true;
  # This adds a user service.
  # Is that needed? Does the keyring start automatically upon requests?
  hm.services.gnome-keyring.enable = true;
  hm.xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common = {
      default = [
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
    config.niri = {
      default = [
        "gtk"
        "gnome"
      ];
      "org.freedesktop.impl.portal.Access" = [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "xdg-desktop-portal-gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "xdg-desktop-portal-gnome" ];
    };
    configPackages = [
      pkgs.niri
    ];
    extraPortals = [
      pkgs.gnome-keyring
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };
  services.displayManager.enable = true;
  imports = [
    ./fuzzel.nix
    #./noctalia.nix
    ./niri.nix
    ./dms.nix
  ];
  hm.home.packages = with pkgs; [
    wdisplays
    wl-clipboard
    wev
  ];
}
