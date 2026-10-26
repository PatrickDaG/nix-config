{ pkgs, ... }:
{
  hm =
    { config, lib, ... }:
    {
      home.persistence."/state".directories = [
        ".cache/noctalia"
        ".local/state/noctalia"
        ".local/share/noctalia/plugins"
      ];

      # The native target supplies the palette, fonts, and opacity, not the old shell integration.
      stylix.targets.noctalia.enable = true;
      # Downloaded plugins do not install their runtime dependencies:
      # Pomodoro uses ffplay from FFmpeg; screen recording uses gpu-screen-recorder and slurp for region selection.
      home.packages = [
        pkgs.ffmpeg
        pkgs.gpu-screen-recorder
        pkgs.slurp
      ];

      systemd.user.services.noctalia.Service.Environment = lib.optional (
        config.home.sessionVariables ? TERMINAL
      ) "TERMINAL=${config.home.sessionVariables.TERMINAL}";

      programs.niri.settings = {
        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-wallpaper$"; } ];
            place-within-backdrop = true;
          }
        ];
        layout.background-color = "transparent";
        overview.workspace-shadow.enable = false;
        debug.honor-xdg-activation-with-invalid-serial = [ ];
      };

      # Noctalia consumes logind Lock and PrepareForSleep itself, holding a sleep-delay
      # inhibitor until secure lock frames are presented. No timed IPC lock helper is needed.
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        checkConfig = true;

        settings = {
          accessibility.ui_scale = 1.0;
          shell = {
            corner_radius_scale = 0.0;
            avatar_path = "/dev/null";
            telemetry_enabled = false;
            app_icon_colorize = false;
            clipboard_enabled = false;
            launch_apps_as_systemd_services = false;
            animation.enabled = false;
            panel = {
              borders = false;
              shadow = false;
              control_center_placement = "attached";
              open_near_click_control_center = true;
              launcher_placement = "floating";
              launcher_position = "center";
            };
            launcher = {
              layout = "simple";
              categories = false;
              app_grid = false;
              track_usage = true;
              sort_by_usage = true;
              pinned = [ ];
            };
            session.actions = [
              {
                action = "lock";
                shortcut = "1";
                countdown_seconds = 0;
              }
              {
                # Plain native Suspend deliberately skips pre-sleep locking.
                action = "lock_and_suspend";
                shortcut = "2";
                countdown_seconds = 0;
              }
              {
                action = "reboot";
                shortcut = "3";
                countdown_seconds = 0;
              }
              {
                action = "logout";
                shortcut = "4";
                countdown_seconds = 0;
              }
              {
                action = "shutdown";
                shortcut = "5";
                countdown_seconds = 0;
              }
              {
                action = "reboot_uefi";
                shortcut = "6";
                countdown_seconds = 0;
              }
            ];
          };

          bar.main = {
            position = "left";
            thickness = 28;
            radius = 0;
            margin_ends = 0;
            margin_edge = 0;
            padding = 2;
            widget_spacing = 2;
            shadow = false;
            compositor_blur = false;
            reserve_space = true;
            capsule = false;
            capsule_radius = 0.0;
            start = [
              "control-center"
              "active_window"
              "workspaces"
            ];
            center = [
              "media"
              "audio_visualizer"
              "clock"
            ];
            end = [
              "tray"
              "pomodoro"
              "cpu"
              "memory"
              "disk"
              "network_rx"
              "network_tx"
              "volume"
              "microphone"
              "privacy"
              "notifications"
              "battery"
            ];
          };

          widget = {
            "control-center" = {
              custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
              custom_image_colorize = false;
            };
            # Native vertical active-window/media widgets render an icon/artwork only.
            active_window = {
              display = "text_only";
              min_length = 0;
              max_length = 500;
              title_scroll = "on_hover";
              show_empty_label = false;
            };
            workspaces = {
              style = "focus_hint";
              show_labels = false;
              show_icons = true;
              max_label_chars = 2;
              hide_when_empty = false;
              show_all_outputs = false;
              focused_output_only = false;
              labels_only_when_occupied = false;
            };
            media = {
              hide_album_art = true;
              artist_first = false;
              hide_when_idle = false;
              hide_when_no_media = false;
              min_length = 0;
              max_length = 145;
              title_scroll = "on_hover";
            };
            audio_visualizer = {
              width = 28;
              show_wave = false;
              show_when_idle = true;
            };
            clock = {
              format = "{:%H:%M %a, %b %d}";
              vertical_format = "{:%H\n%M\n%S}\n-\n{:%d\n%b}";
              color = "primary";
            };
            tray = {
              hidden = [ ];
              pinned = [ ];
              drawer = false;
              hide_passive = false;
            };
            pomodoro.type = "thepunkoff/pomodoro:widget";
            cpu = {
              type = "sysmon";
              stat = "cpu_usage";
              font_scale = 0.8;
            };
            memory = {
              type = "sysmon";
              stat = "ram_pct";
              font_scale = 0.8;
            };
            disk = {
              type = "sysmon";
              stat = "disk_used_pct";
              path = "/state";
              font_scale = 0.8;
            };
            network_rx = {
              type = "sysmon";
              stat = "net_rx";
              font_scale = 0.8;
              network_speed_compact = true;
              network_speed_decimal_places = 0;
            };
            network_tx = {
              type = "sysmon";
              stat = "net_tx";
              font_scale = 0.8;
              network_speed_compact = true;
              network_speed_decimal_places = 0;
            };
            volume.device = "output";
            microphone = {
              type = "volume";
              device = "input";
              hide_when_inactive = false;
            };
            notifications.hide_when_no_unread = true;
            # Battery absence now always hides the widget; there is no force-show option.
            battery = {
              hide_when_plugged = false;
              hide_when_full = false;
            };
          };

          control_center = {
            hidden_tabs = [
              "monitor"
              "network"
            ];
            shortcuts = map (type: { inherit type; }) [
              "noctalia/screen_recorder:toggle"
              "wallpaper"
              "notification"
              "power_profile"
              "caffeine"
              "nightlight"
            ];
            media.show_visualizer = true;
          };

          desktop_widgets.enabled = false;
          dock.enabled = false;
          backdrop.enabled = false;
          system.monitor.enabled = true;
          idle.behavior = {
            lock.enabled = false;
            screen-off.enabled = false;
          };
          nightlight = {
            enabled = false;
            force = false;
            temperature_day = 6500;
            temperature_night = 4000;
          };
          location = {
            auto_locate = false;
            address = "Bochum, Germany";
            custom_schedule = false;
            sunrise = "06:30";
            sunset = "18:30";
          };
          weather = {
            enabled = true;
            unit = "celsius";
            effects = false;
          };

          wallpaper = {
            enabled = true;
            directory = "${config.xdg.dataHome}/wallpapers";
            per_monitor_directories = true;
            transition = [ ];
            # Keep Stylix's palette but never pin its image over the rotating collection.
            default.path = lib.mkForce "";
            automation = {
              enabled = true;
              interval_seconds = 180;
              order = "random";
              recursive = true;
            };
          };

          notification = {
            enable_daemon = true;
            position = "top_right";
            monitors = [ "DP-3" ];
            follow_focused_output = false;
            layer = "overlay";
            # Native filters have no per-urgency duration. Retain the normal 8s
            # timeout and ignore sender timeouts consistently, including permanent ones.
            filter_order = [ "duration" ];
            filter.duration = {
              match_content = ".*";
              override_duration = 8000;
              allow_permanent = false;
              play_sound = false;
            };
          };
          osd.kinds.keyboard_layout = true;
          audio = {
            enable_sounds = false;
            enable_notification_sounds = false;
          };

          lockscreen = {
            enabled = true;
            lock_before_suspend = true;
            grace_period_seconds = 0;
            transition = [ ];
            tint_intensity = 0.2;
          };
          # Compact layout and hidden session buttons now require per-output login-box
          # customization in the lockscreen editor; keep the secure native defaults.

          plugins = {
            enabled = [
              "thepunkoff/pomodoro"
              "noctalia/screen_recorder"
            ];
            source = [
              {
                name = "official";
                kind = "git";
                location = "https://github.com/noctalia-dev/official-plugins";
                enabled = true;
              }
              {
                name = "community";
                kind = "git";
                location = "https://github.com/noctalia-dev/community-plugins";
                enabled = true;
              }
            ];
          };
          plugin_settings."thepunkoff/pomodoro" = {
            work-duration = 50;
            short-break-duration = 10;
            long-break-duration = 30;
            sessions-before-long-break = 3;
            auto-start-breaks = false;
            auto-start-work = false;
            enable-work-timer-sound = false;
            use-bundled-alarm-sound = true;
            bypass-noctalia-sound-globals = true;
          };
        };
      };
    };
}
