{ config, lib, ... }:
let
  nixConfig = config;
in
{
  # import shared i3 config
  imports = [ ../Xorg/sway3.nix ];
  hm =
    { config, ... }:
    {
      stylix.targets.sway.enable = true;
      wayland.windowManager.sway = {
        extraOptions = [
          "--unsupported-gpu"
          "-Dlegacy-wl-drm"
        ];
        enable = true;
        config =
          {
            bars = [ ];
            menu = "fuzzel";
            startup = [
              { command = "uwsm finalize"; }
            ];
            input = {
              "*" = {
                xkb_layout = "de";
                xkb_options = "grp:win_space_toggle";
                repeat_delay = "235";
                repeat_rate = "60";
                accel_profile = "flat";
                pointer_accel = "0.3";
                tap = "enabled";
              };
              "type:touchpad" = {
                pointer_accel = "0.5";
                natural_scroll = "enabled";
              };
              "type:touch" = {
                map_to_output = "eDP-1";
              };
              "type:tablet_tool" = {
                map_to_output = "eDP-1";
              };
            };
            keybindings =
              let
                cfg = config.wayland.windowManager.sway.config;
                modifier = "Mod4";
              in
              {
                "Menu" = "exec ${cfg.menu}";
                "${modifier}+t" = lib.mkForce "exec uwsm app kitty";
                "${modifier}+b" = lib.mkForce "exec uwsm app firefox";
                "${modifier}+m" = lib.mkForce "exec uwsm app thunderbird";
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
                  allow_tearing = "yes";
                  max_render_time = "off";
                };
              };
            };
            patricknix = {
              output = {
                "Acer Technologies XB271HU #ASP7ytE/6A7d" = {
                  mode = "2560x1440@59.951Hz";
                  pos = "0,0";
                };
                "AU Optronics 0x30EB Unknown" = {
                  mode = "3840x2160@60.002Hz";
                  pos = "2560,0";
                  scale = "2";
                };
              };
            };
          }
          .${nixConfig.node.name} or { };
        extraConfig =
          let
            cfg = config.wayland.windowManager.sway.config;
          in
          ''
            bindgesture swipe:3:left workpace next
            bindgesture swipe:3:right workpace prev
            bindgesture pinch:4:outward exec ${cfg.menu}
            output Unknown-1 disable
          '';
      };
      # Cursor invisible
      home.sessionVariables = {
        #WLR_NO_HARDWARE_CURSORS = 1;
        NIXOS_OZONE_WL = 1;
        WLR_DRM_DEVICES = "/dev/dri/card1";
      };
    };
}
