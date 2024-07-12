{
  pkgs,
  lib,
  nixosConfig,
  ...
}: {
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    style =
      ({
          desktopnix = ''
            * {
            	/* `otf-font-awesome` is required to be installed for icons */
            	font-family: "Symbols Nerd Font Mono", "JetBrains Mono";
            	font-size: 13px;
            	transition-duration: .1s;
            }
          '';
          patricknix = ''
            * {
            	/* `otf-font-awesome` is required to be installed for icons */
            	font-family: "Symbols Nerd Font Mono", "JetBrains Mono";
            	font-size: 10px;
            	transition-duration: .1s;
            }
          '';
        }
        .${nixosConfig.node.name}
        or "")
      + builtins.readFile ./waybar.css;
    settings.main = {
      layer = "top";
      position = "bottom";
      modules-left = ["privacy" "hyprland/submap" "hyprland/window"];
      modules-center = ["hyprland/workspaces"];
      modules-right =
        {
          desktopnix = [
            "cpu"
            "memory"
            "wireplumber"
            "network"
            "clock"
            "custom/notification"
            "tray"
          ];
          patricknix = [
            "cpu"
            "memory"
            "wireplumber"
            "network"
            "bluetooth"
            "backlight"
            "battery"
            "clock"
            "custom/notification"
            "tray"
          ];
        }
        .${nixosConfig.node.name}
        or [];

      battery = {
        interval = 1;
        format = "{icon}  {capacity}%";
        format-icons = ["" "" "" "" "" "" "" "" ""];
        states = {
          critical = 10;
          warning = 20;
        };
      };

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = ["󱩎" "󱩏" "󱩐" "󱩑" "󱩒" "󱩓" "󱩔" "󱩕" "󱩖" "󰛨"];
        on-scroll-up = "${pkgs.acpilight}/bin/xbacklight +5";
        on-scroll-down = "${pkgs.acpilight}/bin/xbacklight -5";
      };

      clock = {
        format = "{:%Y-%m-%d %H:%M:%S}";
        interval = 1;
        tooltip = false;
      };

      "custom/notification" = {
        tooltip = false;
        format = "{icon} {}";
        format-icons = {
          notification = "<span foreground='red'><sup></sup></span>";
          none = "";
          dnd-notification = "<span foreground='red'><sup></sup></span>";
          dnd-none = "";
          inhibited-notification = "<span foreground='red'><sup></sup></span>";
          inhibited-none = "";
          dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
          dnd-inhibited-none = "";
        };
        return-type = "json";

        on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
        on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
        on-click-middle = "${pkgs.swaynotificationcenter}/bin/swaync-client --close-all";
        escape = true;
      };

      wireplumber = {
        format = "{icon} {volume}%";
        on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-middle = "${pkgs.hyprland}/bin/hyprctl dispatch exec \"[float;pin;move 80% 50%;size 20% 50%;noborder]\" ${lib.getExe pkgs.pwvucontrol}";
        on-click-right = "${pkgs.hyprland}/bin/hyprctl dispatch exec \"[float]\" ${lib.getExe pkgs.helvum}";
        on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
        on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
        format-muted = "󰖁";
        format-icons = ["󰕿" "󰖀" "󰕾"];
      };

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons.urgent = "";
        all-outputs = false;
        sort-by = "id";
        persistent-workspaces = {
          "DP-3" = [1 2 3 4 5];
          "DVI-D-1" = [6 7];
          "HDMI-A-1" = [8 9];
        };
      };

      "hyprland/window" = {
        separate-outputs = true;
      };

      privacy = {
        icon-spacing = 4;
        icon-size = 18;
        transition-duration = 250;
        modules = [
          {
            type = "screenshare";
            tooltip = true;
            tooltip-icon-size = 24;
          }
          {
            type = "audio-out";
            tooltip = true;
            tooltip-icon-size = 24;
          }
          {
            type = "audio-in";
            tooltip = true;
            tooltip-icon-size = 24;
          }
        ];
      };
      network = {
        interval = 5;
        format-ethernet = "󰈀  <span color='#ffead3'>↓ {bandwidthDownBytes}</span> <span color='#ecc6d9'>↑ {bandwidthUpBytes}</span>";
        format-disconnected = "⚠  Disconnected";
        tooltip = false;
        tooltip-format = "↑ {bandwidthUpBytes}\n↓ {bandwidthDownBytes}";
      };

      bluetooth = {
        format = "  {status} ";
        format-connected = " {device_alias}";
        format-connected-battery = " {device_alias} {device_battery_percentage}%";
        tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
        tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
      };

      memory = {
        interval = 5;
        format = "  {percentage}%";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      cpu = {
        interval = 5;
        format = "  {usage}%";
        tooltip-format = "{usage}";
      };

      tray = {
        icon-size = 21;
        spacing = 10;
      };
    };
  };
}
