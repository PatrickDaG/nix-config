{
  config,
  pkgs,
  ...
}: {
  # import shared sway config
  imports = [../sway3.nix];
  stylix.targets.i3.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      menu = "rofi -show drun";
      keybindings = let
        cfg = config.xsession.windowManager.i3.config;
        maim = "${pkgs.maim}/bin/maim -qs -b 1 --hidecursor";
      in {
        "Menu" = "exec ${cfg.menu}";
        "${cfg.modifier}+c" = "exec ${cfg.menu}";
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
        "${cfg.modifier}+F10" = let
          nsend = ''            ${pkgs.libnotify}/bin/notify-send \
            			-h string:category:Screenshot\
            			-h string:image-path:"${config.images.images."qr.png"}" \
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
}
