{ lib, pkgs, ... }:
let
  swww-update-wallpaper = pkgs.writeShellApplication {
    name = "swww-update-wallpaper";
    runtimeInputs = [
      pkgs.swww
      pkgs.jq
    ];
    text = ''
      FILES=("$HOME/.local/share/wallpapers/"*)
      TYPES=("wipe" "any")
      ANGLES=(0 15 30 45 60 75 90 105 120 135 150 165 180 195 210 225 240 255 270 285 300 315 330 345)

      ## Display separate Wallpaper per output

      readarray -t MONITORS < <(swww query | cut -d ":" -f 1)

      for i in "''${MONITORS[@]}"; do
        swww img -o "$i" \
          "''${FILES[RANDOM%''${#FILES[@]}]}" \
          --transition-type "''${TYPES[RANDOM%''${#TYPES[@]}]}" \
          --transition-angle "''${ANGLES[RANDOM%''${#ANGLES[@]}]}" \
          --transition-fps 144 \
          --transition-duration 1.5
      done
    '';
  };
in
{
  hm.systemd.user = {
    services = {
      swww = {
        Install.WantedBy = [ "graphical-session.target" ];
        Unit.After = [ "graphical-session.target" ];
        Unit = {
          Description = "Wayland wallpaper daemon";
        };
        Service = {
          ExecStart = "${pkgs.swww}/bin/swww-daemon";
          Restart = "on-failure";
        };
      };
      swww-update-wallpaper = {
        Unit.Description = "Update the wallpaper";
        Service = {
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = "2m";
          ExecStart = lib.getExe swww-update-wallpaper;
        };
      };
    };
    timers.swww-update-wallpaper = {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit.After = [ "graphical-session.target" ];
      Unit.Description = "Periodically switch to a new wallpaper";
      Timer.OnCalendar = "*:0/3"; # Every 5 minutes
    };
  };
}
