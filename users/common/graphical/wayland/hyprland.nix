{
  pkgs,
  lib,
  nixosConfig,
  ...
}: let
  inherit
    (lib)
    mkMerge
    optionals
    elem
    mkIf
    flip
    concatMap
    ;
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
            natural_scroll = true;
            disable_while_typing = true;
            clickfinger_behavior = true;
            scroll_factor = 0.7;
          };
        };
        gestures = {
          workspace_swipe = true;
        };

        general = {
          gaps_in = 0;
          gaps_out = 0;
          allow_tearing = true;
        };
        bind = let
          monitor_binds = {
            "1" = "j";
            "2" = "d";
            "3" = "u";
            "4" = "a";
            "5" = "x";
            "6" = "F1";
            "7" = "F2";
            "8" = "F3";
            "9" = "F4";
          };
        in
          [
            "SUPER,q,killactive,"
            "SUPER,return,fullscreen,"
            "SUPER + SHIFT,return,fakefullscreen,"
            "SUPER,f,togglefloating"
            "SUPER,g,togglegroup"
            "SUPER,tab,cyclenext,"
            "ALT,tab,cyclenext,"
            "SUPER+CTRL,r,submap,resize"

            "SUPER,left,movefocus,l"
            "SUPER,right,movefocus,r"
            "SUPER,up,movefocus,u"
            "SUPER,down,movefocus,d"

            "SUPER,n,movefocus,l"
            "SUPER,s,movefocus,r"
            "SUPER,l,movefocus,u"
            "SUPER,r,movefocus,d"

            "SUPER,h,changegroupactive,b"
            "SUPER,m,changegroupactive,f"

            "SUPER + SHIFT,left,movewindoworgroup,l"
            "SUPER + SHIFT,right,movewindoworgroup,r"
            "SUPER + SHIFT,up,movewindoworgroup,u"
            "SUPER + SHIFT,down,movewindoworgroup,d"

            "SUPER + SHIFT,n,movewindoworgroup,l"
            "SUPER + SHIFT,s,movewindoworgroup,r"
            "SUPER + SHIFT,l,movewindoworgroup,u"
            "SUPER + SHIFT,r,movewindoworgroup,d"

            "SUPER,comma,workspace,-1"
            "SUPER,period,workspace,+1"
            "SUPER + SHIFT,comma,movetoworkspace,-1"
            "SUPER + SHIFT,period,movetoworkspace,+1"

            "SUPER,b,exec,firefox"
            "SUPER,m,exec,thunderbird"
            "SUPER,t,exec,kitty"
            ",Menu,exec,fuzzel"
            "SUPER,,exec,${lib.getExe pkgs.scripts.clone-term}"

            "CTRL,F7,sendshortcut,SHIFT+CTRL,m,WebCord"
            "CTRL,F8,sendshortcut,CTRL+SHIFT,d,WebCord"
            "CTRL,F9,exec,systemctl --user start swww-update-wallpaper"

            "SUPER + SHIFT,q,exit"
          ]
          ++ flip concatMap (map toString (lib.lists.range 1 9)) (
            x: [
              "SUPER,${monitor_binds."${x}"},workspace,${x}"
              "SUPER + SHIFT,${monitor_binds."${x}"},movetoworkspacesilent,${x}"
            ]
          );

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
            "_JAVA_AWT_WM_NONREPARENTING,1"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORM,wayland"
            "SDL_VIDEODRIVER,wayland"
            "GDK_BACKEND,wayland"
            "WLR_DRM_NO_ATOMIC,1" #retest on newest nvidia driver
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
          vrr = 1;
          disable_hyprland_logo = true;
          mouse_move_focuses_monitor = false;
        };
        windowrulev2 = [
          "immediate, class:^(cs2)$"
          "float,class:(firefox),title:^(.*)(Bitwarden)(.*)$"
        ];
      }
      (mkIf (nixosConfig.node.name == "desktopnix") {
        monitor = [
          "DVI-D-1,preferred,0x-1080,1"
          "HDMI-A-1,preferred,0x0,1"
          "DP-3,2560x1440@144.00Hz,1920x-540,1"
          # Thank you NVIDIA for this generous, free-of-charge, extra monitor that
          # doesn't exist and crashes yoru session sometimes when moving a window to it.
          "Unknown-1, disable"
        ];

        windowrulev2 = [
          "workspace 2,class:^(firefox)$"
          "workspace 3,class:^(thunderbird)$"
          "workspace 4,class:^(bottles)$"
          "workspace 4,class:^(steam)$"
          "workspace 4,class:^(prismlauncher)$"
          "workspace 6,class:^(discord)$"
          "workspace 6,class:^(WebCord)$"
          "workspace 7,class:^(Signal)$"
          "workspace 7,class:^(TelegramDesktop)$"
        ];

        workspace = [
          "1, monitor:DP-3, default:true"
          "2, monitor:DP-3"
          "3, monitor:DP-3"
          "4, monitor:DP-3"
          "5, monitor:DP-3"
          "6, monitor:DVI-D-1, default:true"
          "7, monitor:DVI-D-1"
          "8, monitor:HDMI-A-1, default: true"
          "9, monitor:HDMI-A-1"
        ];
      })
      (mkIf (nixosConfig.node.name == "patricknix") {
        monitor = [
        ];
        workspace = [
        ];
      })
    ];
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

      exec-once = ${pkgs.xorg.xprop}/bin/xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
      env = XCURSOR_SIZE,48

      binds {
        focus_preferred_method = 1
      }
    '';
  };
}
