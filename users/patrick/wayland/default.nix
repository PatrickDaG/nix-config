{
  pkgs,
  ...
}:
{
  services.dbus = {
    enable = true;
    implementation = "broker";
  };
  xdg.portal.enable = true;
  #services.gnome.gnome-keyring.enable = true;
  # This adds a user service.
  # Is that needed? Does the keyring start automatically upon requests?
  #hm.services.gnome-keyring.enable = true;
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

  security.pam.services.swaylock = { };
  hm.services.swayidle = {
    enable = true;
    events = {
      "before-sleep" = "${pkgs.swaylock}/bin/swaylock -fF";
      "lock" = "${pkgs.swaylock}/bin/swaylock -fF";
    };
  };

  imports = [
    # keep-sorted start
    ./fuzzel.nix
    ./niri.nix
    ./swaync.nix
    ./swww.nix
    ./vicinae.nix
    ./wallpaper-engine.nix
    #./noctalia.nix
    ./waybar
    # keep-sorted end
  ];
  hm.home.packages = with pkgs; [
    # keep-sorted start
    wdisplays
    wev
    wl-clipboard
    # keep-sorted end
  ];
}
