{ pkgs, ... }:
{
  imports = [
    ../.
    ./fuzzel.nix
    ./sway.nix
    ./hyprland.nix
    ./waybar
    ./swaync
    ./swww.nix
  ];
  home.packages = with pkgs; [
    wdisplays
    wl-clipboard
  ];
}
