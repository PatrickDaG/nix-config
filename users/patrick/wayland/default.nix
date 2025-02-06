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
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      # "org.freedesktop.impl.portal.ScreenCast" = [ "xdg-desktop-portal-wlr" ];
      # "org.freedesktop.impl.portal.Screenshot" = [ "xdg-desktop-portal-wlr" ];
      "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  services.displayManager.enable = true;
  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      hyprland = {
        binPath = "/etc/profiles/per-user/patrick/bin/Hyprland";
        prettyName = "Hyprland";
      };
      sway = {
        binPath = "/etc/profiles/per-user/patrick/bin/sway";
        prettyName = "Sway";
      };
    };
  };
  imports = [
    ./fuzzel.nix
    ./sway.nix
    ./hyprland.nix
    ./waybar
    ./swaync
    ./swww.nix
  ];
  hm.home.packages = with pkgs; [
    wdisplays
    wl-clipboard
    wev
  ];
  # Autostart compositor if on tty1 (once, don't restart after logout)
  hm.programs.zsh.initExtra = lib.mkOrder 9999 ''
    if [[ -t 0 && "$(tty || true)" == /dev/tty1 ]] && uwsm check may-start ; then
    	exec systemd-cat -t uwsm_start uwsm start -S -F Hyprland
    fi
  '';
}
