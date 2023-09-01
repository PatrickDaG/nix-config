{pkgs, ...}: {
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = with pkgs; [xdg-desktop-portal-wlr];
  };
}
