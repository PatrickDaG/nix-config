{
  config,
  pkgs,
  ...
}: let
  wallpaper-folder = "${config.home.homeDirectory}/.local/share/wallpapers";
  exe =
    pkgs.writeShellScript "set-wallpaper"
    ''
         ${pkgs.feh}/bin/feh --no-fehbg --bg-fill --randomize \
      $( ${pkgs.findutils}/bin/find ${wallpaper-folder} | ${pkgs.ripgrep}/bin/rg ".*(\.png|\.jpg)$")
    '';
in {
  systemd.user = {
    timers = {
      set-wallpaper = {
        Unit = {
          Description = "Set a random wallpaper every 3 minutes";
        };
        Timer = {
          OnUnitActiveSec = "3 min";
        };
        Install.WantedBy = [
          "timers.target"
        ];
      };
    };
    services = {
      set-wallpaper = {
        Unit = {
          Description = "Set a random wallpaper on all X displays";
          ConditionEnvironment = "DISPLAY";
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
