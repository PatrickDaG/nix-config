{ pkgs, inputs, ... }:
{
  #hm.stylix.targets.vicinae.enable = true;
  hm = {
    services.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
        environment = {
          USE_LAYER_SHELL = 1;
        };
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
        };
        providers = {
          raycast-compat.enabled = false;
        };
      };
      extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
        # keep-sorted start
        bluetooth
        #dbus
        firefox
        fuzzy-files
        niri
        nix
        player-pilot
        port-killer
        power-profile
        process-manager
        #systemd
        pulseaudio
        wifi-commander
        # keep-sorted end
      ];
    };
    programs.niri.settings = {
      # Allow vicinae to activate other windows
      debug.honor-xdg-activation-with-invalid-serial = [ ];
    };
  };
}
