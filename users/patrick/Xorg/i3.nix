{
  pkgs,
  ...
}:
{
  # import shared sway config
  imports = [ ./sway3.nix ];
  # To add the session
  services.xserver.windowManager.i3 = {
    enable = true;
    extraSessionCommands = ''
      xset r rate 235 60
    '';
  };

  hm =
    { config, ... }:
    {
      stylix.targets.i3.enable = true;
      xsession.windowManager.i3 = {
        enable = true;
        enableSystemdTarget = true;
        config = {
          startup = [
            {
              command = "${pkgs.xorg.xrandr}/bin/xrandr --output DVI-D-0 --mode 1920x1080 --pos 0x0 --rate 60.00 --output DP-4 --mode 2560x1440 --pos 1920x720 --primary --rate 144 --output HDMI-0 --pos 0x1080 --rate 60.00";
            }
          ];
          menu = "rofi -show drun";
          keybindings =
            let
              cfg = config.xsession.windowManager.i3.config;
            in
            {
              "Menu" = "exec ${cfg.menu}";
              "Ctrl+F9" = "exec ${config.xsession.wallpapers.script}";
            };
        };
      };
      # programs.i3status-rust = {
      #   enable = true;
      #   bars.main = {
      #     blocks =
      #       [
      #         { block = "net"; }
      #         {
      #           block = "cpu";
      #           format = " $icon  $utilization ";
      #         }
      #         {
      #           block = "nvidia_gpu";
      #           format = " $icon  $utilization $memory $temperature ";
      #         }
      #       ]
      #       ++ {
      #         "patricknix" = [ { block = "battery"; } ];
      #       }
      #       .${nixConfig.node.name} or [ ]
      #       ++ [
      #         {
      #           block = "sound";
      #           click = [
      #             {
      #               button = "left";
      #               action = "toggle_mute";
      #             }
      #           ];
      #         }
      #         {
      #           block = "backlight";
      #           missing_format = "";
      #         }
      #         {
      #           block = "time";
      #           format = "$icon  $timestamp.datetime(f:'%a %d.%m.%y %H:%M:%S') ";
      #           interval = 1;
      #         }
      #       ];
      #     theme = "native";
      #     # currently nixpgs-wayland breaks this
      #     # icons = "material-nf";
      #     settings = {
      #       icons.icons = "material-nf";
      #       icons.overrides = {
      #         cpu = " ";
      #       };
      #     };
      #   };
      # };
    };
}
