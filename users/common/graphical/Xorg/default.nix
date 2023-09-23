{pkgs, ...}: {
  home.packages = [pkgs.xclip];
  imports = [
    ../.
    ./rofi.nix
    ./autorandr.nix
    ./i3.nix
    ./wallpapers.nix
  ];
  home.file.".xinitrc".source = ./xinitrc;
}
