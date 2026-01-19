{
  config,
  pkgs,
  lib,
  ...
}:
let
  nconfig = config;
in
{
  programs.niri.enable = true;
  hm =
    { config, ... }:
    {
      stylix.targets.niri.enable = true;
      programs.niri.settings = nconfig.lib.misc.mkPerHost {
        all = {
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-stable;

          input = {
            keyboard = {
              xkb = {
                layout = "de";
                variant = "nodeadkeys";
              };
              repeat-delay = 235;
              repeat-rate = 60;
            };
            touchpad = {
              tap = true;
              dwt = true;
              dwtp = true;
              natural-scroll = true;
              accel-profile = "flat";
            };
            mouse = {
              accel-speed = 0.2;
              accel-profile = "flat";
            };
            power-key-handling.enable = false;

            workspace-auto-back-and-forth = true;
          };
          gestures.hot-corners.enable = false;
          binds = with config.lib.niri.actions; {

            "Mod+T".action = spawn "kitty";
            "Mod+c".action = spawn "clone-term";
            "Mod+b".action = spawn "firefox";
            "Menu".action = spawn "vicinae" "toggle";
            "Super+Alt+L".action = spawn "systemctl suspend";
            XF86AudioRaiseVolume = {
              action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
              allow-when-locked = true;
            };
            XF86AudioLowerVolume = {
              action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
              allow-when-locked = true;
            };
            XF86AudioMute = {
              action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
              allow-when-locked = true;
            };
            XF86AudioMicMute = {
              action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
              allow-when-locked = true;
            };
            "Mod+Q".action = close-window;

            "Mod+n".action = focus-column-left;
            "Mod+left".action = focus-column-left;
            "Mod+Shift+n".action = move-column-left;
            "Mod+Shift+left".action = move-column-left;

            "Mod+r".action = focus-window-or-workspace-down;
            "Mod+down".action = focus-window-or-workspace-down;
            "Mod+Shift+r".action = move-window-down;
            "Mod+Shift+down".action = move-window-down;

            "Mod+l".action = focus-window-or-workspace-up;
            "Mod+up".action = focus-window-or-workspace-up;
            "Mod+Shift+l".action = move-window-up;
            "Mod+Shift+up".action = move-window-up;

            "Mod+s".action = focus-column-right;
            "Mod+right".action = focus-column-right;
            "Mod+Shift+s".action = move-column-right;
            "Mod+Shift+right".action = move-column-right;

            "Mod+h".action = focus-column-first;
            "Mod+Shift+h".action = consume-or-expel-window-left;
            "Mod+m".action = focus-column-last;
            "Mod+Shift+m".action = consume-or-expel-window-right;

            "Mod+Ctrl+n".action = focus-monitor-left;
            "Mod+Shift+Ctrl+n".action = move-column-to-monitor-left;
            "Mod+Ctrl+r".action = focus-monitor-down;
            "Mod+Shift+Ctrl+r".action = move-column-to-monitor-down;
            "Mod+Ctrl+l".action = focus-monitor-up;
            "Mod+Shift+Ctrl+l".action = move-column-to-monitor-up;
            "Mod+Ctrl+s".action = focus-monitor-right;
            "Mod+Shift+Ctrl+s".action = move-column-to-monitor-right;

            "Mod+Period".action = focus-workspace-down;
            "Mod+Shift+Period".action = move-column-to-workspace-down;
            "Mod+Ctrl+Period".action = move-workspace-down;
            "Mod+comma".action = focus-workspace-up;
            "Mod+Shift+comma".action = move-column-to-workspace-up;
            "Mod+Ctrl+comma".action = move-workspace-up;

            "Mod+WheelScrollDown" = {
              action = focus-workspace-down;
              cooldown-ms = 150;
            };
            "Mod+WheelScrollUp" = {
              action = focus-workspace-up;
              cooldown-ms = 150;
            };
            "Mod+Ctrl+WheelScrollDown" = {
              action = move-column-to-workspace-down;
              cooldown-ms = 150;
            };
            "Mod+Ctrl+WheelScrollUp" = {
              action = move-column-to-workspace-up;
              cooldown-ms = 150;
            };
            "Mod+WheelScrollRight".action = focus-column-right;
            "Mod+WheelScrollLeft".action = focus-column-left;
            "Mod+Ctrl+WheelScrollRight".action = move-column-right;
            "Mod+Ctrl+WheelScrollLeft".action = move-column-left;
            "Mod+Shift+WheelScrollDown".action = focus-column-right;
            "Mod+Shift+WheelScrollUp".action = focus-column-left;
            "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
            "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

            "Mod+V".action = maximize-column;
            "Mod+Ctrl+V".action = expand-column-to-available-width;
            "Mod+return".action = fullscreen-window;
            "Mod+Minus".action = set-column-width "-10%";
            "Mod+Shift+0".action = set-column-width "+10%";

            "Mod+F".action = toggle-window-floating;
            "Mod+Ctrl+F".action = switch-focus-between-floating-and-tiling;

            "Mod+y".action = toggle-column-tabbed-display;

            #"Print".action = screenshot;
            #"Ctrl+Print".action = screenshot-screen {};
            #"Alt+Print".action = screenshot-window;

            "Mod+Escape" = {
              action = toggle-keyboard-shortcuts-inhibit;
              allow-inhibiting = false;
            };

            # The quit action will show a confirmation dialog to avoid accidental exits.
            "Mod+Ctrl+Escape".action = quit;
            # Powers off the monitors. To turn them back on, do any input like
            # moving the mouse or pressing any other key.
            "Mod+Shift+P".action = power-off-monitors;

            # You can refer to workspaces by index. However, keep in mind that
            # niri is a dynamic workspace system, so these commands are kind of
            # "best effort". Trying to refer to a workspace index bigger than
            # the current workspace count will instead refer to the topmost
            # (empty) workspace.
            #
            # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
            # will all refer to the 3rd workspace.
            # keep this one just in case. All configs should have a "default" workspace
            "Mod+j".action = focus-workspace "default";
            "Mod+Shift+j".action.move-window-to-workspace = "default";

          };

          window-rules = [
            {
              matches = [ { app-id = "firefox"; } ];
              open-on-workspace = "default";
            }

            {
              matches = [ { app-id = "thunderbird"; } ];
              open-on-workspace = "mail";
              block-out-from = "screen-capture";
            }
            {
              matches = [ { app-id = "steam"; } ];
              open-on-workspace = "games";
            }

            {
              matches = [ { app-id = "Element"; } ];
              open-on-workspace = "comms";
            }
            {
              matches = [ { app-id = "signal"; } ];
              open-on-workspace = "comms";
            }
            {
              matches = [ { app-id = "discord"; } ];
              open-on-workspace = "comms";
            }
            {
              matches = [ { app-id = "Slack"; } ];
              open-on-workspace = "slack";
            }
            {
              matches = [ { app-id = "Zulip"; } ];
              open-on-workspace = "slack";
            }

            {
              matches = [ { app-id = "obsidian"; } ];
              open-on-workspace = "notes";
              block-out-from = "screencast";
            }
            {
              matches = [ { app-id = "Zotero"; } ];
              open-on-workspace = "notes";
              block-out-from = "screencast";
            }
            {
              matches = [ { app-id = "com.saivert.pwvucontrol"; } ];
              open-floating = true;
              default-column-width = {
                proportion = 0.2;
              };
              default-window-height = {
                proportion = 0.6;
              };
              default-floating-position = {
                x = 42;
                y = 42;
                "relative-to" = "bottom-right";
              };
            }
            {
              matches = [ { app-id = "org.pipewire.Helvum"; } ];
              open-floating = true;
              default-column-width = {
                proportion = 0.2;
              };
              default-window-height = {
                proportion = 0.6;
              };
              default-floating-position = {
                x = 42;
                y = 42;
                "relative-to" = "bottom-right";
              };
            }

          ];

          spawn-at-startup = [
            { command = [ "obsidian" ]; }
            { command = [ "firefox" ]; }
          ];

          prefer-no-csd = true;
          hotkey-overlay = {
            skip-at-startup = true;
          };
          layout = {
            gaps = 1;
            center-focused-column = "never";
            empty-workspace-above-first = true;
            preset-column-widths = [
              { proportion = 0.33333; }
              { proportion = 0.5; }
              { proportion = 0.66667; }
            ];
            default-column-width = {
              proportion = 0.5;
            };
            preset-window-heights = [
              { proportion = 0.33333; }
              { proportion = 0.5; }
              { proportion = 0.66667; }
            ];
            focus-ring = {
              enable = true;
              width = 2;
              active.color = "#7fc8ff";
              inactive.color = "#505050";
            };
            border = {
              enable = false;
              width = 2;
              active.color = "#ffc87f";
              inactive.color = "#505050";
            };
            shadow = {
              # on
              softness = 30;
              spread = 5;
              offset = {
                x = 0;
                y = 5;
              };
              draw-behind-window = true;
              color = "#00000070";
              # inactive-color "#00000054"
            };
            tab-indicator = {
              # off
              hide-when-single-tab = true;
              place-within-column = true;
              gap = 5;
              width = 4;
              length = {
                total-proportion = 1.0;
              };
              position = "right";
              gaps-between-tabs = 2;
              corner-radius = 8;
              active.color = "red";
              inactive.color = "gray";
            };
            insert-hint = {
              # off
              display.color = "#ffc87f80";
            };
          };
        };
        desktopnix = {
          input.tablet = {
            map-to-output = "DP-3";
          };
          outputs."DP-3" = {
            mode = {
              width = 2560;
              height = 1440;
              refresh = 143.998;
            };
            #scale 2.0
            position = {
              x = 1920;
              y = 0;
            };
            variable-refresh-rate = "on-demand";
          };
          outputs."HDMI-A-1" = {
            position = {
              x = 0;
              y = 512;
            };
          };
          workspaces = {
            "1default" = {
              name = "default";
              open-on-output = "DP-3";
            };
            "2mail" = {
              name = "mail";
              open-on-output = "DP-3";
            };
            "3games" = {
              name = "games";
              open-on-output = "DP-3";
            };

            "1browser" = {
              name = "browser";
              open-on-output = "HDMI-A-1";
            };
            "2notes" = {
              name = "notes";
              open-on-output = "HDMI-A-1";
            };
            "3comms" = {
              name = "comms";
              open-on-output = "HDMI-A-1";
            };
          };
          binds = with config.lib.niri.actions; {
            "Mod+d".action = focus-workspace "mail";
            "Mod+Shift+d".action.move-window-to-workspace = "mail";

            "Mod+u".action = focus-workspace "games";
            "Mod+Shift+u".action.move-window-to-workspace = "games";

            "Mod+F1".action = focus-workspace "browser";
            "Mod+Shift+F1".action.move-window-to-workspace = "browser";

            "Mod+F2".action = focus-workspace "notes";
            "Mod+Shift+F2".action.move-window-to-workspace = "notes";

            "Mod+F3".action = focus-workspace "comms";
            "Mod+Shift+F3".action.move-window-to-workspace = "comms";
          };

          spawn-at-startup = [
            { command = [ "thunderbird" ]; }
          ];
        };
        patricknix = {
          outputs."eDP-1" = {
            scale = 2.0;
            position = {
              x = 2560 * 2;
              y = 960;
            };
          };
          outputs."DP-2" = {
            position = {
              x = 0;
              y = 0;
            };
          };
          outputs."DP-3" = {
            position = {
              x = 2560;
              y = 0;
            };
          };
          workspaces = {
            "1notes" = {
              name = "notes";
              open-on-output = "eDP-1";
            };
            "1default" = {
              name = "default";
              open-on-output = "DP-3";
            };
            "2mail" = {
              name = "mail";
              open-on-output = "DP-3";
            };
            "1second" = {
              name = "second";
              open-on-output = "DP-2";
            };
            "2slack" = {
              name = "slack";
              open-on-output = "DP-2";
            };
          };
          binds = with config.lib.niri.actions; {
            "Mod+d".action = focus-workspace "mail";
            "Mod+Shift+d".action.move-window-to-workspace = "mail";

            "Mod+F1".action = focus-workspace "second";
            "Mod+Shift+F1".action.move-window-to-workspace = "second";

            "Mod+F2".action = focus-workspace "slack";
            "Mod+Shift+F2".action.move-window-to-workspace = "slack";

            "Mod+F3".action = focus-workspace "notes";
            "Mod+Shift+F3".action.move-window-to-workspace = "notes";
          };
          spawn-at-startup = [
            { command = [ "thunderbird" ]; }
            { command = [ "zotero" ]; }
          ];
        };
        thinknix = {
          outputs."eDP-1" = {
            scale = 1.5;
            position = {
              x = 2560 * 2;
              y = 960;
            };
          };
          outputs."DP-7" = {
            position = {
              x = 0;
              y = 0;
            };
          };
          outputs."DP-5" = {
            position = {
              x = 2560;
              y = 0;
            };
          };
          workspaces = {
            "1notes" = {
              name = "notes";
              open-on-output = "eDP-1";
            };
            "1default" = {
              name = "default";
              open-on-output = "DP-5";
            };
            "2mail" = {
              name = "mail";
              open-on-output = "DP-5";
            };
            "1second" = {
              name = "second";
              open-on-output = "DP-7";
            };
            "2slack" = {
              name = "slack";
              open-on-output = "DP-7";
            };
          };
          binds = with config.lib.niri.actions; {
            "Mod+d".action = focus-workspace "mail";
            "Mod+Shift+d".action.move-window-to-workspace = "mail";

            "Mod+F1".action = focus-workspace "second";
            "Mod+Shift+F1".action.move-window-to-workspace = "second";

            "Mod+F2".action = focus-workspace "slack";
            "Mod+Shift+F2".action.move-window-to-workspace = "slack";

            "Mod+F3".action = focus-workspace "notes";
            "Mod+Shift+F3".action.move-window-to-workspace = "notes";
          };
          spawn-at-startup = [
            { command = [ "thunderbird" ]; }
            { command = [ "zotero" ]; }
            { command = [ "slack" ]; }
            { command = [ "zulip" ]; }
          ];
        };

      };
      home.packages = [
        pkgs.pat-scripts.clone-term
      ];
    };
}
