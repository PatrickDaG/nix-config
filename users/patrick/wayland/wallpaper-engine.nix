{

  hm =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      asset-dir = "$HOME/.local/share/Steam/steamapps/workshop/content/431960";
      script = pkgs.writeShellApplication {
        name = "wallpaper-engine";
        runtimeInputs = [
          pkgs.jq
        ];
        text = ''
          FILES=("${asset-dir}"/*)
          ${
            lib.concatStringsSep " " (
              [
                (lib.getExe pkgs.linux-wallpaperengine)
                "--silent"
                "--fps 30"
                "--clamp border"
              ]
              ++ (lib.mapAttrsToList (name: _: ''
                --screen-root ${name} \
                --bg "$(basename "''${FILES[RANDOM%''${#FILES[@]}]}")" \
              '') config.programs.niri.settings.outputs)
            )
          # This shit programs spams the journal with TUI things
          } > /dev/null'';
      };
    in
    {
      systemd.user = {
        services.linux-wallpaperengine = {
          Install.WantedBy = [ "graphical-session.target" ];
          Unit.After = [ "graphical-session.target" ];
          Unit.Description = "Wallpaper backgrounds";
          Service = {
            Restart = "always";
            RestartSec = "0s";
            ExecStart = lib.getExe script;
            RuntimeMaxSec = "180s";
          };
        };
      };
    };
}
