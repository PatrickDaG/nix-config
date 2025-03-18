{ pkgs, ... }:
{
  programs.niri.enable = true;
  hm.xdg.configFile."niri/config.kdl".source = ./niri.kdl;
  hm.home.packages = [
    pkgs.xwayland-satellite
    pkgs.scripts.clone-term
  ];
}
