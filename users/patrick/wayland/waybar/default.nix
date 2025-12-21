{
  pkgs,
  lib,
  config,
  ...
}:
{
  hm.systemd.user.services."waybar" = {
    Unit.After = [
      "graphical-session.target"
      "pipewire.service"
      "wireplumber.service"
    ];
    Service.Slice = [ "app-graphical.slice" ];
  };
  hm.programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = config.lib.misc.mkPerHost {
      all = builtins.readFile ./waybar.css;
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
    };
    settings.main = {
      layer = "top";
      position = "bottom";
      modules-left = [
        "privacy"
        "niri/window"
      ];
      modules-center = [ "niri/workspaces" ];
      modules-right = config.lib.misc.mkPerHost {
        desktopnix = [
          "cpu"
          "memory"
          "wireplumber"
          "network"
          "clock"
          "tray"
          "custom/notification"
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
          "tray"
          "custom/notification"
        ];
      };

      battery = {
        interval = 1;
        format = "{icon}  {capacity}%";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
          ""
          ""
          ""
          ""
        ];
        states = {
          critical = 10;
          warning = 20;
        };
      };

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = [
          "󱩎"
          "󱩏"
          "󱩐"
          "󱩑"
          "󱩒"
          "󱩓"
          "󱩔"
          "󱩕"
          "󱩖"
          "󰛨"
        ];
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
        exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";

        on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
        on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
        on-click-middle = "${pkgs.swaynotificationcenter}/bin/swaync-client --close-all";
        escape = true;
      };

      wireplumber = {
        format = "{icon} {volume}%";
        on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-middle = lib.getExe pkgs.pwvucontrol;
        on-click-right = lib.getExe pkgs.helvum;
        format-muted = "󰖁";
        format-icons = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
      };
      "niri/workspaces" = {
        format = "{icon}";
        format-icons.urgent = "";
        all-outputs = false;
      };
      "niri/window" = {
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
        format-ethernet = "󰈀  <span color='#ffead3'>↓ {bandwidthDownBytes:>5}</span> <span color='#ecc6d9'>↑ {bandwidthUpBytes:>5}</span>";
        format-disconnected = "⚠  Disconnected";
        tooltip = false;
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
