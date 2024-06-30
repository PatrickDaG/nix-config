{
  pkgs,
  lib,
  nixosConfig,
  ...
}: let
  inherit (lib) mkMerge optionals elem;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = mkMerge [
      {
        input = {
          kb_layout = "de";
          kb_variant = "nodeadkeys";
          follow_mouse = 2;
          numlock_by_default = true;
          repeat_rate = 60;
          repeat_delay = 235;
          # Only change focus on mouse click
          float_switch_override_focus = 0;
          accel_profile = "flat";

          touchpad = {
            natural_scroll = "true";
            disable_while_typing = true;
            clickfinger_behavior = true;
            scroll_factor = 0.7;
          };
        };

        general = {
          gaps_in = 1;
          gaps_out = 0;
          allow_tearing = true;
        };

        cursor.no_warps = true;
        debug.disable_logs = false;
        env =
          optionals (elem "nvidia" nixosConfig.services.xserver.videoDrivers) [
            # See https://wiki.hyprland.org/Nvidia/
            "LIBVA_DRIVER_NAME,nvidia"
            "XDG_SESSION_TYPE,wayland"
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          ]
          ++ [
            "NIXOS_OZONE_WL,1"
            "MOZ_ENABLE_WAYLAND,1"
            "MOZ_WEBRENDER,1"
            "_JAVA_AWT_WM_NONREPARENTING,1"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORM,wayland"
            "SDL_VIDEODRIVER,wayland"
            "GDK_BACKEND,wayland"
          ];
        bindm = [
          # mouse movements
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
          "SUPER ALT, mouse:272, resizewindow"
        ];
        animations = {
          enabled = true;
          animation = [
            "windows, 1, 4, default, slide"
            "windowsOut, 1, 4, default, slide"
            "windowsMove, 1, 4, default"
            "border, 1, 2, default"
            "fade, 1, 4, default"
            "fadeDim, 1, 4, default"
            "workspaces, 1, 4, default"
          ];
        };

        decoration.rounding = 4;
        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user restart xdg-desktop-portal.service"
          "${pkgs.waybar}/bin/waybar"
          "${pkgs.swaynotificationcenter}/bin/swaync"
        ];
        misc = {
          vfr = 1;
          vrr = 1;
          disable_hyprland_logo = true;
          mouse_move_focuses_monitor = false;
        };
        extraConfig = ''
          submap=resize
          binde=,right,resizeactive,80 0
          binde=,left,resizeactive,-80 0
          binde=,up,resizeactive,0 -80
          binde=,down,resizeactive,0 80
          binde=SHIFT,right,resizeactive,10 0
          binde=SHIFT,left,resizeactive,-10 0
          binde=SHIFT,up,resizeactive,0 -10
          binde=SHIFT,down,resizeactive,0 10
          bind=,return,submap,reset
          bind=,escape,submap,reset
          submap=reset

          env=WLR_DRM_NO_ATOMIC,1
          windowrulev2 = immediate, class:^(cs2)$

          binds {
            focus_preferred_method = 1
          }
        '';
      }
    ];
  };
}
