{pkgs, ...}: {
  home.packages = [
    pkgs.xclip
    pkgs.xdragon
  ];
  imports = [
    ../.
    ./rofi.nix
    ./i3.nix
    ./wallpapers.nix
  ];
  home.file.".xinitrc".source = ./xinitrc;
}
