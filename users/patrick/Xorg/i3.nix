{
  pkgs,
  ...
}:
{
  # import shared sway config
  imports = [ ./sway3.nix ];

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
              maim = "${pkgs.maim}/bin/maim -qs -b 1 --hidecursor";
            in
            {
              "Menu" = "exec ${cfg.menu}";
              "Ctrl+F9" = "exec ${config.xsession.wallpapers.script}";
              "${cfg.modifier}+F12" =
                "exec "
                + toString (
                  pkgs.writeShellScript "clipboard-screenshot" ''
                    ${maim} | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png
                  ''
                );
              "${cfg.modifier}+F11" =
                "exec "
                + toString (
                  pkgs.writeShellScript "clipboard-screenshot" ''
                    out="screenshot-$(date +"%Y-%m-%dT%H:%M:%S%:z")"
                    ${maim} | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png
                  ''
                );
              "${cfg.modifier}+F10" =
                let
                  nsend = ''
                    ${pkgs.libnotify}/bin/notify-send \
                          -h string:category:Screenshot\
                  '';
                in
                "exec "
                + toString (
                  pkgs.writeShellScript "clipboard-qr-screenshot" ''
                    set -euo pipefail
                    if qr=$(${maim} | ${pkgs.zbar}/bin/zbarimg -q --raw -); then
                    	return=$?
                    else
                    	return=$?
                    fi
                    case "$return" in
                    	"0")
                    		${nsend} "Copied qr to clipboard"
                    		${pkgs.xclip}/bin/xclip -selection clipboard -f <<< ''${qr%"''${qr##*[![:space:]]}"}
                    		exit 0
                    	;;
                    	"4")
                    		${nsend} "No qr found"
                    	;;
                    	*)
                    		${nsend} "Failure scanning qr"
                    	;;
                    esac
                  ''
                );
              "${cfg.modifier}+F9" =
                "exec "
                + toString (
                  pkgs.writeShellScript "clipboard-ocr-screenshot" ''
                    set -euo pipefail
                    qr=$(${maim} | ${pkgs.zbar}/bin/zbarimg -q --raw -) || true
                    case "$?" in
                    	0)
                    		${pkgs.libnotify}/bin/notify-send -h string:category:"Screenshot" "Copied qr to clipboard"
                    		${pkgs.xclip}/bin/xclip -selection clipboard -f <<< ''${qr%"''${qr##*[![:space:]]}"}
                    		exit 0
                    	;;
                    	4)
                    		${pkgs.libnotify}/bin/notify-send -h string:category:"Screenshot" "No qr found"
                    	;;
                    	*)
                    		${pkgs.libnotify}/bin/notify-send -h string:category:"Screenshot" "Failure scanning qr"
                    	;;
                    esac
                  ''
                );
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
