_: {

  hm =
    { config, lib, ... }:
    {
      home.persistence."/state".directories = [
        ".cache/noctalia"
      ];
      stylix.targets.noctalia-shell.enable = true;
      programs.niri.settings = {
        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-wallpaper*"; } ];
            place-within-backdrop = true;
          }
        ];
        layout = {
          background-color = "transparent";
        };

        overview = {
          workspace-shadow.enable = false;
        };
        debug.honor-xdg-activation-with-invalid-serial = [ ];
      };
      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true;

        settings = {
          audio = {
            preferredPlayer = "spotify";
            visualizerType = "wave";
          };
          desktopWidgets.enabled = false;
          hooks.enabled = false;
          idle.enabled = false;
          nightLight = {
            autoSchedule = true;
            dayTemp = "6500";
            enabled = false;
            forced = false;
            manualSunrise = "06:30";
            manualSunset = "18:30";
            nightTemp = "4000";
          };
          sessionMenu = {
            enableCountdown = false;
            powerOptions = [
              {
                action = "lock";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "1";
              }
              {
                action = "suspend";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "2";
              }
              {
                action = "hibernate";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
              {
                action = "reboot";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "3";
              }
              {
                action = "logout";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "4";
              }
              {
                action = "shutdown";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "5";
              }
              {
                action = "rebootToUefi";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "6";
              }
              {
                action = "userspaceReboot";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
            ];
          };
          systemMonitor.enableDgpuMonitoring = true;
          bar = {
            density = "mini";
            position = "left";
            showCapsule = false;
            outerCorners = false;
            "showOutline" = false;
            enableExclusionZoneInset = false;
            widgets = {
              "left" = [
                {
                  "colorizeDistroLogo" = false;
                  "colorizeSystemIcon" = "none";
                  "customIconPath" = "";
                  "enableColorization" = false;
                  "icon" = "noctalia";
                  "id" = "ControlCenter";
                  "useDistroLogo" = true;
                }
                {
                  "colorizeIcons" = false;
                  "hideMode" = "visible";
                  "id" = "ActiveWindow";
                  "maxWidth" = 500;
                  "scrollingMode" = "hover";
                  "showIcon" = false;
                  "useFixedWidth" = false;
                }
                {
                  "characterCount" = 2;
                  "colorizeIcons" = false;
                  "enableScrollWheel" = true;
                  "followFocusedScreen" = false;
                  "hideUnoccupied" = false;
                  "id" = "Workspace";
                  "labelMode" = "none";
                  "showApplications" = true;
                  "showLabelsOnlyWhenOccupied" = false;
                }
              ];
              "center" = [
                {
                  "hideMode" = "visible";
                  "hideWhenIdle" = false;
                  "id" = "MediaMini";
                  "maxWidth" = 145;
                  "scrollingMode" = "hover";
                  "showAlbumArt" = false;
                  "showArtistFirst" = false;
                  "showProgressRing" = true;
                  "showVisualizer" = true;
                  "useFixedWidth" = false;
                  "visualizerType" = "linear";
                }
                {
                  "customFont" = "";
                  "formatHorizontal" = "HH:mm ddd, MMM dd";
                  "formatVertical" = "HH mm ss - dd MMM";
                  "id" = "Clock";
                  "useCustomFont" = false;
                  "usePrimaryColor" = true;
                }
              ];
              "right" = [
                {
                  "blacklist" = [
                  ];
                  "colorizeIcons" = false;
                  "drawerEnabled" = false;
                  "hidePassive" = false;
                  "id" = "Tray";
                  "pinned" = [
                  ];
                }
                {
                  id = "plugin:pomodoro";
                }
                {
                  "diskPath" = "/state";
                  "id" = "SystemMonitor";
                  "showCpuTemp" = false;
                  "showCpuUsage" = true;
                  "showDiskUsage" = true;
                  "showGpuTemp" = false;
                  "showMemoryAsPercent" = true;
                  "showMemoryUsage" = true;
                  "showNetworkStats" = true;
                  "usePrimaryColor" = false;
                }
                {
                  "displayMode" = "alwaysShow";
                  "id" = "Volume";
                }
                {
                  "displayMode" = "alwaysShow";
                  "id" = "Microphone";
                }
                {
                  "id" = "plugin:privacy-indicator";
                }
                {
                  "hideWhenZero" = true;
                  "id" = "NotificationHistory";
                  "showUnreadBadge" = true;
                }
                {
                  id = "Battery";
                  hideIfNotDetected = false;
                }
              ];
            };
          };
          "controlCenter" = {
            "position" = "close_to_bar_button";
            "shortcuts" = {
              "left" = [
                {
                  "id" = "ScreenRecorder";
                }
                {
                  "id" = "WallpaperSelector";
                }
              ];
              "right" = [
                {
                  "id" = "Notifications";
                }
                {
                  "id" = "PowerProfile";
                }
                {
                  "id" = "KeepAwake";
                }
                {
                  "id" = "NightLight";
                }
              ];
            };
            "cards" = [
              {
                "enabled" = true;
                "id" = "profile-card";
              }
              {
                "enabled" = true;
                "id" = "shortcuts-card";
              }
              {
                "enabled" = true;
                "id" = "audio-card";
              }
              {
                "enabled" = false;
                "id" = "brightness-card";
              }
              {
                "enabled" = true;
                "id" = "weather-card";
              }
              {
                "enabled" = true;
                "id" = "media-sysmon-card";
              }
            ];
          };
          general = {
            radiusRatio = 0;
            "avatarImage" = "/dev/null";
            "allowPanelsOnScreenWithoutBar" = true;
            "animationDisabled" = true;
            "animationSpeed" = 2;
            "boxRadiusRatio" = 1;
            "compactLockScreen" = true;
            "dimmerOpacity" = 0.2;
            "enableShadows" = false;
            "lockOnSuspend" = true;
            "scaleRatio" = 1;
            "screenRadiusRatio" = 1;
            "shadowDirection" = "bottom_right";
            "shadowOffsetX" = 2;
            "shadowOffsetY" = 3;
            "showHibernateOnLockScreen" = false;
            "showScreenCorners" = false;
            "showSessionButtonsOnLockScreen" = false;
            telemetryEnabled = false;
          };
          wallpaper = {
            enabled = true;
            directory = "${config.xdg.dataHome}/wallpapers";
            overviewEnabled = false;
            "enableMultiMonitorDirectories" = false;
            "transitionType" = [ "random" ];
            wallpaperChangeMode = "random";
            "randomIntervalSec" = 180;
          };
          notifications = {
            enabled = true;
            "criticalUrgencyDuration" = 15;
            "enableKeyboardLayoutToast" = true;
            "location" = "top_right";
            "lowUrgencyDuration" = 3;
            "monitors" = [
              "DP-3"
            ];
            "normalUrgencyDuration" = 8;
            "overlayLayer" = true;
            "respectExpireTimeout" = false;
            "sounds" = {
              "criticalSoundFile" = "";
              "enabled" = false;
              "excludedApps" = "discord,firefox,chrome,chromium,edge";
              "lowSoundFile" = "";
              "normalSoundFile" = "";
              "separateSounds" = false;
              "volume" = 0.5;
            };
          };
          location = {
            name = "Bochum, Germany";
            firstDayOfWeek = 0;
          };
          dock.enabled = false;
          # Only networkmanager supported
          network.wifiEnabled = false;
          "appLauncher" = {
            "customLaunchPrefix" = "";
            "customLaunchPrefixEnabled" = false;
            "enableClipPreview" = false;
            "enableClipboardHistory" = false;
            "pinnedExecs" = [
            ];
            "position" = "center";
            "showCategories" = false;
            "sortByMostUsed" = true;
            "terminalCommand" = "kitty -e";
            "useApp2Unit" = false;
            "viewMode" = "list";
          };
        };
        pluginSettings = {
          pomodoro = {
            "workDuration" = 50;
            "shortBreakDuration" = 10;
            "longBreakDuration" = 30;
            "sessionsBeforeLongBreak" = 3;
            "autoStartBreaks" = false;
            "autoStartWork" = false;
            "compactMode" = true;
            "playSound" = true;
          };
        };
        plugins = {
          sources = [
            {
              enabled = true;
              name = "Official Noctalia Plugins";
              url = "https://github.com/noctalia-dev/noctalia-plugins";
            }
          ];
          states = {
            pomodoro = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
            "privacy-indicator" = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
          };
          version = 2;
        };
      };
      home.file.".cache/noctalia/wallpapers.json".text = lib.mkForce (builtins.toJSON { });
    };
}
