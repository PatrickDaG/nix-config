{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    # enable workspaces
    package = pkgs.waybar.overrideAttrs (prevAttrs: {
      mesonFlags = prevAttrs.mesonFlags ++ ["-Dexperimental=true"];
    });
    settings = {
      main = {
        layer = "top";
        position = "bottom";
        modules-left = ["hyprland/window"];
        modules-center = ["wlr/workspaces"];
        # wireplumber module seems to be currently broken
        modules-right = ["network" "wireplumber" "backlight" "battery" "clock" "tray"];

        battery = {
          format = "{icon}  {capacity}%";
          format-icons = ["" "" "" "" "" "" "" "" ""];
        };

        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = ["󱩎" "󱩏" "󱩐" "󱩑" "󱩒" "󱩓" "󱩔" "󱩕" "󱩖" "󰛨"];
          on-scroll-up = "${pkgs.acpilight}/bin/xbacklight +5";
          on-scroll-down = "${pkgs.acpilight}/bin/xbacklight -5";
        };

        clock.format = "{:%Y-%m-%d %H:%M}";

        wireplumber = {
          format = "{icon} {volume}%";
          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          format-muted = "󰖁";
          format-icons = ["󰕿" "󰖀" "󰕾"];
        };

        network = {
          format = "{ifname}  {bandwidthUpBits}  {bandwidthDownBits}";
          interval = 1;
        };
      };
    };
    style = ./waybar.css;
  };
}
