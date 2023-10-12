{
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    types
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    ;
  settingsFormat = pkgs.formats.json {};
in {
  home-manager.sharedModules = [
    ({config, ...}: {
      options.programs.streamdeck-ui = {
        enable = mkEnableOption "streamdeck-ui";
        package = mkPackageOption pkgs "streamdeck-ui" {};
        settings = mkOption {
          default = {};
          type = types.submodule {freeformType = settingsFormat.type;};
          description = "Configuration per streamdeck";
        };
      };
      config = mkIf config.programs.streamdeck-ui.enable {
        systemd.user = {
          services = {
            streamdeck = {
              Unit = {
                Description = "start streamdeck-ui";
                # For some reason this depends on X or wayland running
                ConditionEnvironment = ["DISPLAY" "WAYLAND_DISPLAYS"];
              };
              Service = {
                Type = "exec";
                ExecStart = "${pkgs.streamdeck-ui}/bin/streamdeck-ui --no-ui";
                Environment = "STREAMDECK_UI_CONFIG=${config.xdg.configHome}/streamdeck-ui/config.json";
              };
              Install.WantedBy = ["graphical-session.target"];
            };
          };
        };

        xdg.configFile.streamdeck-ui = {
          target = "streamdeck-ui/config.json";
          source = settingsFormat.generate "config.json" {
            streamdeck_ui_version = 1;
            state = config.programs.streamdeck-ui.settings;
          };
        };
      };
    })
  ];
}
