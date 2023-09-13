{
  config,
  pkgs,
  lib,
  nixosConfig,
  ...
}: {
  home.packages = [
    pkgs.wdisplays
  ];
  wayland.windowManager.sway = {
    enable = true;
    config =
      {
        modifier = "Mod4";
        terminal = "kitty";
        menu = "fuzzel";
        input = {
          "*" = {
            xkb_layout = "de,de";
            # games are stupid so the main ui has to be de() without bone
            xkb_variant = ",bone";
            xkb_options = "grp:win_space_toggle";
            repeat_delay = "235";
            repeat_rate = "60";
            accel_profile = "flat";
            pointer_accel = "0.5";
          };
          "type:touchpad" = {
            natural_scroll = "enabled";
          };
        };

        focus = {
          followMouse = false;
          mouseWarping = false;
        };
        down = "r";
        left = "n";
        right = "s";
        up = "l";
        #bindkeysToCode = true;
        window.titlebar = false;
        keybindings = let
          cfg = config.wayland.windowManager.sway.config;
        in {
          "${cfg.modifier}+t" = "exec ${cfg.terminal}";
          "${cfg.modifier}+b" = "exec firefox";
          "Menu" = "exec ${cfg.menu}";
          "${cfg.modifier}+q" = "kill";

          "${cfg.modifier}+${cfg.left}" = "focus left";
          "${cfg.modifier}+${cfg.down}" = "focus down";
          "${cfg.modifier}+${cfg.up}" = "focus up";
          "${cfg.modifier}+${cfg.right}" = "focus right";

          "${cfg.modifier}+Left" = "focus left";
          "${cfg.modifier}+Down" = "focus down";
          "${cfg.modifier}+Up" = "focus up";
          "${cfg.modifier}+Right" = "focus right";

          "${cfg.modifier}+Shift+${cfg.left}" = "move left";
          "${cfg.modifier}+Shift+${cfg.down}" = "move down";
          "${cfg.modifier}+Shift+${cfg.up}" = "move up";
          "${cfg.modifier}+Shift+${cfg.right}" = "move right";

          "${cfg.modifier}+Shift+Left" = "move left";
          "${cfg.modifier}+Shift+Down" = "move down";
          "${cfg.modifier}+Shift+Up" = "move up";
          "${cfg.modifier}+Shift+Right" = "move right";

          "${cfg.modifier}+x" = "splith";
          "${cfg.modifier}+v" = "splitv";
          "${cfg.modifier}+Return" = "fullscreen toggle";

          "${cfg.modifier}+j" = "layout stacking";
          "${cfg.modifier}+d" = "layout tabbed";
          "${cfg.modifier}+u" = "layout toggle split";

          "${cfg.modifier}+f" = "floating toggle";
          "${cfg.modifier}+space" = "focus mode_toggle";

          "${cfg.modifier}+Comma" = "workspace prev";
          "${cfg.modifier}+Period" = "workspace next";

          "${cfg.modifier}+1" = "workspace number 1";
          "${cfg.modifier}+2" = "workspace number 2";
          "${cfg.modifier}+3" = "workspace number 3";
          "${cfg.modifier}+4" = "workspace number 4";
          "${cfg.modifier}+5" = "workspace number 5";
          "${cfg.modifier}+6" = "workspace number 6";
          "${cfg.modifier}+7" = "workspace number 7";
          "${cfg.modifier}+8" = "workspace number 8";
          "${cfg.modifier}+9" = "workspace number 9";

          "${cfg.modifier}+Shift+1" = "move container to workspace number 1";
          "${cfg.modifier}+Shift+2" = "move container to workspace number 2";
          "${cfg.modifier}+Shift+3" = "move container to workspace number 3";
          "${cfg.modifier}+Shift+4" = "move container to workspace number 4";
          "${cfg.modifier}+Shift+5" = "move container to workspace number 5";
          "${cfg.modifier}+Shift+6" = "move container to workspace number 6";
          "${cfg.modifier}+Shift+7" = "move container to workspace number 7";
          "${cfg.modifier}+Shift+8" = "move container to workspace number 8";
          "${cfg.modifier}+Shift+9" = "move container to workspace number 9";
        };
      }
      // {
        desktopnix = {
          output = {
            DVI-D-1 = {
              mode = "1920x1080@60Hz";
              pos = "0,0";
            };
            HDMI-A-1 = {
              mode = "1920x1080@60Hz";
              pos = "0,1080";
            };
            DP-3 = {
              mode = "2560x1440@143.998Hz";
              pos = "1920,720";
              adaptive_sync = "on";
            };
          };
          workspaceOutputAssign = [
            {
              workspace = "1";
              output = "DP-3";
            }
            {
              workspace = "2";
              output = "HDMI-A-1";
            }
            {
              workspace = "2";
              output = "DVI-D-1";
            }
          ];
        };
      }
      .${nixosConfig.node.name}
      or {};
  };
  # Cursor invisible
  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = 1;
    NIXOS_OZONE_WL = 1;
    # opengl backend flickers, also vulkan is love.
    #WLR_RENDERER = "vulkan";
  };
}
