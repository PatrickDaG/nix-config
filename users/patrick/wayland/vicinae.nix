{
  pkgs,
  inputs,
  ...
}:
{
  #hm.stylix.targets.vicinae.enable = true;
  hm = {
    services.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
      settings = {
        close_on_focus_loss = true;
        consider_preedit = true;
        pop_to_root_on_close = true;
        favicon_service = "twenty";
        #escape_key_behaviour = "close_window";
        font = {
          normal = {
            size = 12;
            normal = "Maple Nerd Font";
          };
        };
        theme = {
          light = {
            name = "vicinae-light";
            icon_theme = "default";
          };
          dark = {
            name = "vicinae-dark";
            icon_theme = "Papirus";
          };
        };
        launcher_window = {
          opacity = 0.98;
          layer_shell = {
            layer = "overlay";
          };
        };
        providers = {
          raycast-compat.enabled = false;
          "files" = {
            "preferences" = {
              "excludedPaths" = "/home/patrick/smb";
            };
          };
          "core" = {
            "entrypoints" = {
              "about" = {
                "enabled" = false;
              };
              "documentation" = {
                "enabled" = false;
              };
              "keybind-settings" = {
                "enabled" = false;
              };
              "list-extensions" = {
                "enabled" = false;
              };
              "manage-fallback" = {
                "enabled" = false;
              };
              "oauth-token-store" = {
                "enabled" = false;
              };
              "open-config-file" = {
                "enabled" = false;
              };
              "open-default-config" = {
                "enabled" = false;
              };
              "report-bug" = {
                "enabled" = false;
              };
              "sponsor" = {
                "enabled" = false;
              };
              "store" = {
                "enabled" = false;
              };
            };
          };
          "developer" = {
            "enabled" = false;
          };
          "font" = {
            "enabled" = false;
          };
          "power" = {
            "entrypoints" = {
              "hibernate" = {
                "enabled" = false;
              };
              "lock" = {
                "enabled" = false;
                "preferences" = {
                  "customProgram" = "heheheha";
                };
              };
              "sleep" = {
                "enabled" = false;
              };
              "soft-reboot" = {
                "enabled" = false;
              };
            };
          };
          "theme" = {
            "enabled" = false;
          };
          "wm" = {
            "enabled" = false;
          };
        };
      };
      extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
        # keep-sorted start
        bluetooth
        #dbus # Currently broken nix build due to 'node-gyp'
        fuzzy-files
        firefox
        mullvad
        niri
        nix
        player-pilot
        port-killer
        power-profile
        process-manager
        #systemd # Currently broken nix build due to 'node-gyp'
        pulseaudio
        #wifi-commander # Only works with network manager
        # keep-sorted end
      ];
    };
    programs.niri.settings = {
      # Allow vicinae to activate other windows
      debug.honor-xdg-activation-with-invalid-serial = [ ];
    };
  };
  # needed by power-profile extension
  # TODO: Errors on switch even though it works seems to be a delayed switch
  services.tlp.pd.enable = true;
  environment.systemPackages = [
    pkgs.power-profiles-daemon
  ];
}
