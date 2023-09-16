{
  config,
  pkgs,
  nixosConfig,
  lib,
  ...
}: {
  home.packages = [
    pkgs.wdisplays
  ];
  wayland.windowManager.sway = {
    enable = true;
    config =
      lib.attrsets.recursiveUpdate
      (import ../sway3.nix)
      {
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
        keybindings = let
          cfg = config.wayland.windowManager.sway.config;
        in {
          "Menu" = "exec ${cfg.menu}";
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
