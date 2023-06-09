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
        modules-left = ["custom/timer" "hyprland/window"];
        modules-center = ["wlr/workspaces"];
        # wireplumber module seems to be currently broken
        modules-right = ["network" "backlight" "battery" "clock" "tray"];

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
        "wlr/workspaces" = {
          on-click = "activate";
        };

        "custom/timer" = {
          exec = "${pkgs.python3}/bin/python ${./timer.py}";
          on-click = "${pkgs.python3}/bin/python ${./timer.py} -s";
          on-click-right = "${pkgs.python3}/bin/python ${./timer.py} -x";
          on-scroll-up = "${pkgs.python3}/bin/python ${./timer.py} -i";
          on-scroll-down = "${pkgs.python3}/bin/python ${./timer.py} -d";
          interval = 1;
        };
      };
    };
    style = ./waybar.css;
  };
}
