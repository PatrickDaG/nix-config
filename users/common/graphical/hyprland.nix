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
        modules-right = ["network" "backlight" "wireplumber" "battery" "clock" "tray"];

        battery = {
          format = "{icon} {capacity}%";
          format-icons = ["" "" "" "" "" "" "" "" ""];
        };

        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = ["" ""];
          on-scroll-up = "${pkgs.acpilight}/bin/xbacklight +5";
          on-scroll-down = "${pkgs.acpilight}/bin/xbacklight -5";
        };

        clock.format = "{:%Y-%m-%d %H:%M}";

        wireplumber = {
          format = "{icon} {volume}%";
          format-muted = "";
          format-icons = ["奄" "奔" "墳"];
        };

        network = {
          format = "{ifname}  {bandwidthUpBits}  {bandwidthDownBits}";
        };
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    nvidiaPatches = true;
    extraConfig = import ../../../data/hyprland/config.nix MOD TAGS pkgs;
  };
}
