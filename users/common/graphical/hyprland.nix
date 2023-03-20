{
  pkgs,
  lib,
  ...
}: let
  MOD = "SUPER";
  TAGS = map toString (lib.lists.range 42 50);
in {
  home.packages = with pkgs; [
    qt6.qtwayland
  ];

  programs.waybar = {
    enable = true;
    settings = {
      main = {
        layer = "top";
        position = "bottom";
        modules-left = ["hyprland/window"];
        modules-center = ["workspaces"];
        modules-right = ["network" "memory" "backlight" "wireplumber" "battery" "clock" "tray"];
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    nvidiaPatches = true;
    extraConfig = import ../../../data/hyprland/config.nix MOD TAGS pkgs;
  };
}
