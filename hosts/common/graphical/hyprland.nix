{pkgs, ...}: {
  programs.hyprland = {
    enableNvidiaPatches = true;
    enable = true;
  };
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    # we just use the hyprland desktop portal
    wlr.enable = false;
    extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
  };
}
