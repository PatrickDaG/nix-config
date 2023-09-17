{
  config,
  pkgs,
  ...
}: let
  wallpaper-folder = "${config.home.homeDirectory}/.local/share/wallpapers";
  exe =
    pkgs.writeShellScript "set-wallpaper"
    ''
      if [ -d "/tmp/.X11-unix" ]; then
           for D in /tmp/.X11-unix/*; do
           	file=$(${pkgs.coreutils}/bin/basename $D)
           	DISPLAY=":''${file:1}" ${pkgs.feh}/bin/feh --no-fehbg --bg-fill --randomize --recursive ${wallpaper-folder}/
           done
      fi
    '';
in {
  systemd.user = {
    timers = {
      set-wallpaper = {
        Unit = {
          Description = "Set a random wallpaper every 3 minutes";
        };
        Timer = {
          OnActiveSec = "0 sec";
          OnUnitActiveSec = "3 min";
        };
        Install.WantedBy = ["timers.target"];
      };
    };
    services = {
      set-wallpaper = {
        Unit = {
          Description = "Set a random wallpaper on all X displays";
        };
        Service = {
          Type = "oneshot";
          ExecStart =
            exe;
        };
      };
    };
  };
  home.persistence."/state".directories = [".local/share/wallpapers"];
}
