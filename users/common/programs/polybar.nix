# Polybar config
# Polybar is kinda weird in two regards:
# 1. polybar allows a superkey and subkey to both have values eg:
# a = "lel"
# a.b = "lul"
# since nix does not allow this you have to hardcode the key with a '-'
# instead of using actual nix subkeys witt '.' eg:
# a = "lel"
# a-b = "lul"
# 2. polybar allows integer keys. In nix these have to be quoted
{
  lib,
  pkgs,
  ...
}: let
  color = {
    shade1 = "#311B92";
    shade2 = "#4527A0";
    shade3 = "#512DA8";
    shade4 = "#5E35B1";
    shade5 = "#673AB7";
    shade6 = "#7E57C2";
    shade7 = "#9575CD";
    shade8 = "#B39DDB";

    bground = "#1D1F28";
    fground = "#f7f7f7";
    borderbg = "#f7f7f7";
    accent = "#5E35B1";
    modulefg = "#f7f7f7";
    modulefg-alt = "#f7f7f7";

    trans = "#00000000";
    white = "#FFFFFF";
    black = "#000000";

    # Material Colors
    red = "#e53935";
    pink = "#d81b60";
    purple = "#8e24aa";
    deep-purple = "#5e35b1";
    indigo = "#3949ab";
    blue = "#1e88e5";
    light-blue = "#039be5";
    cyan = "#00acc1";
    teal = "#00897b";
    green = "#43a047";
    light-green = "#7cb342";
    lime = "#c0ca33";
    yellow = "#fdd835";
    amber = "#ffb300";
    orange = "#fb8c00";
    deep-orange = "#f4511e";
    brown = "#6d4c41";
    grey = "#757575";
    blue-gray = "#546e7a";
  };

  fontsize = "9";
in {
  services.polybar = {
    enable = true;

    package = pkgs.polybar.override {
      pulseSupport = true;
      alsaSupport = true;
      iwSupport = true;
    };

    script = "polybar main @";
    settings = {
      "bar/main" = {
        monitor = "DP-1";
        monitor-fallback = "eDP-1";
        bottom = true;

        # for UHD Polybar
        dpi = 144;
        height = 33;
        # for HD Polybar
        #dpi = 96;
        #height = 22;
        offset.x = "0%";
        offset.y = "0%";

        background = color.bground;
        foreground = color.fground;

        font = {
          "0" = "FiraCode Nerd Font Mono:style=Medium:size=${fontsize};2";
          "1" = "";
          "2" = "Iosevka Nerd Font:style=Medium:size=12;2";
          "3" = "Font Awesome 5 Pro:style=Solid:size=${fontsize}";
          "4" = "FontAwesome:style=Regular:size=${fontsize};2";
          "5" = "Font Awesome 5 Pro:style=Light:size=${fontsize}";
        };

        modules = with lib; {
          left = concatStringsSep " " ["left1" "title" "left2"];
          center = concatStringsSep " " ["workspaces"];
          right = concatStringsSep " " ["right5" "alsa" "right4" "battery" "right3" "network" "right2" "date" "right1" "keyboardswitcher"];
        };

        tray = {
          position = "right";
          background = color.shade1;
        };

        enable.ipc = true;
      };
      # Functional MODULES

      "module/title" = {
        type = "internal/xwindow";

        format = "<label>";
        format-background = color.shade2;
        format-foreground = color.modulefg;
        format-padding = "1";

        label = "%title%";
        label-maxlen = "30";

        label-empty = "NixOS";
        label-empty-foreground = "#707880";
      };

      "module/workspaces" = {
        type = "internal/xworkspaces";

        pin.workspaces = "false";
        enable.click = "true";
        enable.scroll = "false";

        label.active = "%{T1}%{T-}";
        label.occupied = "%{T1}%{T-}";
        label.urgent = "%{T1}%{T-}";
        label.empty = "%{T1}%{T-}";

        format = "<label-state>";

        label.monitor = "%name%";
        label.active-foreground = color.accent;
        label.occupied-foreground = color.yellow;
        label.urgent-foreground = color.red;
        label.empty-foreground = color.modulefg-alt;

        label.active-padding = "1";
        label.urgent-padding = "1";
        label.occupied-padding = "1";
        label.empty-padding = "1";
      };

      "module/alsa" = {
        type = "internal/pulseaudio";

        format.volume = "<ramp-volume> <label-volume>";
        format.volume-background = color.shade5;
        format.volume-foreground = color.modulefg;
        format.volume-padding = "1";

        label.volume = "%percentage%%";

        format.muted.prefix = "%{T1}婢%{T-}";
        label.muted = " Mute";
        format.muted.background = color.shade5;
        format.muted.foreground = color.modulefg;
        format.muted.padding = "1";

        ramp.volume."0" = "%{T1}奄%{T-}";
        ramp.volume."1" = "%{T1}奔%{T-}";
        ramp.volume."2" = "%{T1}墳%{T-}";
      };

      "module/battery" = {
        type = "internal/battery";

        full.at = "99";

        battery = "BAT0";
        adapter = "ADP1";

        poll.interval = "2";
        time.format = "%H:%M";

        format.charging = "<animation-charging> <label-charging>";
        format.charging-background = color.shade4;
        format.charging-foreground = color.modulefg;
        format.charging-padding = "1";

        format.discharging = "<ramp-capacity> <label-discharging>";
        format.discharging-background = color.shade4;
        format.discharging-foreground = color.modulefg;
        format.discharging-padding = "1";

        label.charging = "%percentage%%";
        label.discharging = "%percentage%%";

        label.full = "Fully Charged";
        label.full-background = color.shade4;
        label.full-foreground = color.modulefg;
        label.full-padding = "1";

        # Capacity ramp
        ramp.capacity.font = "5";
        ramp.capacity."0" = "  %{T1}warning%{T-}  ";
        ramp.capacity."0-foreground" = "#000000";
        ramp.capacity."0-background" = "#df2c00";
        ramp.capacity."1" = "";
        ramp.capacity."1-foreground" = "#df2c00";
        ramp.capacity."2" = "";
        ramp.capacity."2-foreground" = "#df4c00";
        ramp.capacity."3" = "";
        ramp.capacity."3-foreground" = "#df8c00";
        ramp.capacity."4" = "";
        ramp.capacity."4-foreground" = "#dfcc00";
        ramp.capacity."5" = "";
        ramp.capacity."5-foreground" = "#dfcc00";
        ramp.capacity."6" = "";
        ramp.capacity."7" = "";
        ramp.capacity."8" = "";
        ramp.capacity."9" = "";

        animation.charging.font = "5";
        animation.charging."0" = "";
        animation.charging."1" = "";
        animation.charging."2" = "";
        animation.charging."3" = "";
        animation.charging."4" = "";
        animation.charging."5" = "";
        animation.charging."6" = "";
        animation.charging."7" = "";
        animation.charging."8" = "";
        animation.charging.framerate = "750";
      };
      "module/date" = {
        type = "internal/date";

        interval = "1.0";
        format = "<label>";
        format-background = color.shade2;
        format-foreground = color.modulefg;
        format-padding = "1";
        label = "%date% %time%";

        # Normal date and time format
        #date.alt = "%%{T5}%%{T-} %{F#808080}%Y.%m.%{F.}%d";
        #time.alt = "%%{T5}%%{T-} %H:%M";

        # Alternative date and time format
        date = "%{T5}%{T-} %a, %d %{F#808080}%b %Y%{F-}";
        time = "%{T5}%{T-} %H:%M:%S";
      };

      "module/network" = {
        type = "internal/network";
        interface = "wlan0";

        interval = "1.0";
        accumulate.stats = "true";
        unknown.as.up = "true";

        format-connected = "<label-connected>";
        format-connected-background = color.shade3;
        format-connected-foreground = color.modulefg;
        format-connected-padding = "1";
        label.connected = "%{F#808080}%ifname%%{F-} %{F#808080}%upspeed:8%   %downspeed:8% %{F-}";

        format.disconnected = "<label-disconnected>";
        format.disconnected-background = color.shade3;
        format.disconnected-foreground = color.modulefg;
        format.disconnected-padding = "1";
      };

      "module/keyboardswitcher" = {
        type = "custom/menu";

        expand.right = "true";

        format.background = color.shade1;
        format.foreground = color.modulefg;

        label.open = "%{T3}  %{T-}";
        label.close = " x ";
        label.separator = " | ";

        menu."0"."0" = "bone";
        menu."0"."0-exec" = "/usr/bin/setxkbmap de bone";
        menu."0"."1" = "neo";
        menu."0"."1-exec" = "/usr/bin/setxkbmap de neo";
        menu."0"."2" = "qwertz";
        menu."0"."2-exec" = "/usr/bin/setxkbmap de";
      };

      # AESTHETIC MODULES

      "module/left1" = {
        type = "custom/text";
        "content-background" = color.shade2;
        "content-foreground" = color.shade1;
        content = "%{T3}%{T-}";
      };

      "module/left2" = {
        type = "custom/text";
        "content-background" = color.bground;
        "content-foreground" = color.shade2;
        content = "%{T3}%{T-}";
      };

      "module/right1" = {
        type = "custom/text";
        "content-background" = color.shade2;
        "content-foreground" = color.shade1;
        content = "%{T3}%{T-}";
      };

      "module/right2" = {
        type = "custom/text";
        "content-background" = color.shade3;
        "content-foreground" = color.shade2;
        content = "%{T3}%{T-}";
      };

      "module/right3" = {
        type = "custom/text";
        "content-background" = color.shade4;
        "content-foreground" = color.shade3;
        content = "%{T3}%{T-}";
      };

      "module/right4" = {
        type = "custom/text";
        "content-background" = color.shade5;
        "content-foreground" = color.shade4;
        content = "%{T3}%{T-}";
      };

      "module/right5" = {
        type = "custom/text";
        "content-background" = color.bground;
        "content-foreground" = color.shade5;
        content = "%{T3}%{T-}";
      };

      "module/right6" = {
        type = "custom/text";
        "content-background" = color.shade7;
        "content-foreground" = color.shade6;
        content = "%{T3}%{T-}";
      };

      "module/right7" = {
        type = "custom/text";
        "content-background" = color.bground;
        "content-foreground" = color.shade7;
        content = "%{T3}%{T-}";
      };
    };
  };
}
