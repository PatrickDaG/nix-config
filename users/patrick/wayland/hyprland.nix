{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    optionals
    elem
    flip
    concatMap
    ;
  #from https://github.com/hyprwm/Hyprland/issues/3835
  float_script = pkgs.writeShellScript "hyprland-bitwarden-float" ''
    handle() {
      case $1 in
        windowtitle*)
          # Extract the window ID from the line
          window_id=''${1#*>>}

          # Fetch the list of windows and parse it using jq to find the window by its decimal ID
          window_info=$(hyprctl clients -j | ${pkgs.jq}/bin/jq --arg id "0x$window_id" '.[] | select(.address == ($id))')

          # Extract the title from the window info
          window_title=$(echo "$window_info" | ${pkgs.jq}/bin/jq '.title')

          # Check if the title matches the characteristics of the Bitwarden popup window
          if [[ "$window_title" == '"Extension: (Bitwarden Password Manager) - Bitwarden — Mozilla Firefox"' ]]; then

            # echo $window_id, $window_title
            # hyprctl dispatch togglefloating address:0x$window_id
            # hyprctl dispatch resizewindowpixel exact 20% 40%,address:0x$window_id
            # hyprctl dispatch movewindowpixel exact 40% 30%,address:0x$window_id

            hyprctl dispatch togglefloating address:0x$window_id
            hyprctl dispatch resizewindowpixel exact "512 768",address:0x$window_id
            hyprctl dispatch movewindowpixel exact "$HYPRLAND_FLOAT_LOCATION",address:0x$window_id
          fi
          ;;
      esac
    }

    # Listen to the Hyprland socket for events and process each line with the handle function
    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
  '';
in
{
  #systemd.user.services.opentabletdriver.after = [ "hyprland-session.target" ];
  hm = {
    # UWSM starts a SH to read env variables
    # this ensures all home.sessionVars are exported
    programs.bash.enable = true;

    # Force use of nvidia gpu on desktopnix
    home.sessionVariables = config.lib.misc.mkPerHost {
      desktopnix = {
        AQ_DRM_DEVICES = "/dev/dri/card1";
      };
    };
    wayland.windowManager.hyprland = {
      enable = true;
      settings = config.lib.misc.mkPerHost {
        all = {
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
              scroll_factor = 0.7;
            };
          };
          device = {
            name = "xp-pen-g430s-pen";
            active_area_size = "48 27";
          };
          gestures = {
            workspace_swipe = true;
          };

          general = {
            gaps_in = 0;
            gaps_out = 0;
            allow_tearing = true;
          };
          #render = {
          #  explicit_sync = 0;
          #  direct_scanout = false;
          #};
          binds = {
            focus_preferred_method = 1;
            workspace_center_on = 1;
          };
          bind =
            let
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
              "SUPER + SHIFT,return,fullscreenstate,2,0,"
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

              "SUPER,b,exec,uwsm app -- firefox"
              "SUPER,t,exec,uwsm app -- kitty"
              ",Menu,exec,fuzzel"
              "SUPER,c,exec,${lib.getExe pkgs.scripts.clone-term}"

              "CTRL,F7,pass,class:^(discord)$"
              "CTRL,F8,pass,class:^(discord)$"
              "CTRL,F7,pass,class:^(TeamSpeak 3)$"
              "CTRL,F8,pass,class:^(TeamSpeak 3)$"
              "CTRL,F9,exec,systemctl --user start swww-update-wallpaper"

              "SUPER + SHIFT,q,exec,uwsm stop"
            ]
            ++ flip concatMap (map toString (lib.lists.range 1 9)) (x: [
              "SUPER,${monitor_binds."${x}"},workspace,${x}"
              "SUPER + SHIFT,${monitor_binds."${x}"},movetoworkspacesilent,${x}"
            ]);

          cursor.no_warps = true;
          debug.disable_logs = false;
          env =
            [
              "NIXOS_OZONE_WL,1"
              "MOZ_ENABLE_WAYLAND,1"
              "_JAVA_AWT_WM_NONREPARENTING,1"
              "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
              "QT_QPA_PLATFORM,wayland;xcb"
              "GDK_BACKEND,wayland"
              "WLR_DRM_NO_ATOMIC,1" # retest on newest nvidia driver
              "XDG_SESSION_TYPE,wayland"
              "TERMINAL,uwsm app -- kitty"
            ]
            ++ optionals (elem "nvidia" config.services.xserver.videoDrivers) [
              # See https://wiki.hyprland.org/Nvidia/
              "LIBVA_DRIVER_NAME,nvidia"
              "GBM_BACKEND,nvidia-drm"
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
          misc = {
            vrr = 1;
            disable_hyprland_logo = true;
            mouse_move_focuses_monitor = false;
          };
          xwayland.force_zero_scaling = true;
          windowrulev2 = [
            # fix these once nvidia gets their shit together
            #"immediate, class:^(cs2)$"
            # apex legends
            "immediate, class:^(steam_app_1172470)$"
            #???
            "immediate, class:^(steam_app_238960)$"
            #baldur
            #"immediate, class:^(steam_app_1086940)$"
            "float, class:^(steam)$, title:^(Friends List)"
            "float, class:^(steam)$, title:(Chat)"

            "float, class:^(streamlink-twitch-gui)$"

            "workspace 2,class:^(firefox)$"
            "workspace 3,class:^(thunderbird)$"
            "workspace 4,class:^(bottles)$"
            "workspace 4,class:^(steam)$, title:^(Steam)"
            "workspace 4,class:^(prismlauncher)$"
            "workspace 6,class:^(discord)$"
            "workspace 6,class:^(WebCord)$"
            "workspace 6,class:^(TeamSpeak 3)$"
            "workspace 7,class:^(signal)$"
            "workspace 7,class:^(TelegramDesktop)$"
          ];
        };
        desktopnix = {
          input.tablet = {
            output = "DP-3";
          };
          monitor = [
            "DVI-D-1,preferred,0x0,1"
            "HDMI-A-1,preferred,0x1080,1"
            "DP-3,2560x1440@144.00Hz,1920x540,1"
            # Thank you NVIDIA for this generous, free-of-charge, extra monitor that
            # doesn't exist and crashes yoru session sometimes when moving a window to it.
            "Unknown-1, disable"
          ];
          workspace = [
            "1, monitor:DP-3, default:true"
            "2, monitor:DP-3"
            "3, monitor:DP-3"
            "4, monitor:DP-3"
            "5, monitor:DP-3"
            "6, monitor:DVI-D-1, default:true"
            "7, monitor:DVI-D-1"
            "8, monitor:HDMI-A-1, default:true"
            "9, monitor:HDMI-A-1"
          ];
          env = [ "HYPRLAND_FLOAT_LOCATION,3800 680" ];
        };
        patricknix = {
          monitor = [
            "eDP-1,preferred,0x0,2"
            # Thank you NVIDIA for this generous, free-of-charge, extra monitor that
            # doesn't exist and crashes yoru session sometimes when moving a window to it.
            "Unknown-1, disable"
          ];
          workspace = [
            "1, monitor:eDP-1, default:true"
            "2, monitor:eDP-1"
            "3, monitor:eDP-1"
            "4, monitor:eDP-1"
            "5, monitor:eDP-1"
            "6, monitor:eDP-1"
            "7, monitor:eDP-1"
            "8, monitor:eDP-1"
            "9, monitor:eDP-1"
          ];
          env = [ "HYPRLAND_FLOAT_LOCATION,1400 200" ];
        };
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

        exec-once = ${pkgs.xorg.xprop}/bin/xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
        exec-once = ${float_script}
        env = XCURSOR_SIZE,48
        exec-once = uwsm finalize
      '';
    };
  };
}
