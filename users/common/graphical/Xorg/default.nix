{ pkgs, ... }:
{
  home.packages = [
    pkgs.xclip
    pkgs.xdragon
  ];
  imports = [
    ../.
    ./rofi.nix
    ./i3.nix
  ];
  xsession.wallpapers.enable = true;
  home.file.".xinitrc".source = ./xinitrc;
}
