{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    # Users should provide their own package
    package = null;
  };
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];
}
