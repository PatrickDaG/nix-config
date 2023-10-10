{
  config,
  pkgs,
  ...
}: let
  wallpaper-folder = "${config.home.homeDirectory}/.local/share/wallpapers";
  exe =
    pkgs.writeShellScript "set-wallpaper"
    ''
      ${pkgs.feh}/bin/feh --no-fehbg --bg-fill --randomize --recursive ${wallpaper-folder}/
    '';
in {
  systemd.user = {
    timers = {
      set-wallpaper = {
        Unit = {
          Description = "Set a random wallpaper every 3 minutes";
        };
        Timer = {
          OnActiveSec = "5 sec";
          OnUnitActiveSec = "3 min";
        };
        Install.WantedBy = [
          "timers.target"
          "graphical-session.target"
        ];
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
