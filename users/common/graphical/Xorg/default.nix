{pkgs, ...}: {
  home.packages = [pkgs.xclip];
  imports = [
    ./herbstluft.nix
    ./rofi.nix
    ./polybar.nix
    ./autorandr.nix
    ./i3.nix
    ./wallpapers.nix
  ];
}
