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
        home.packages = [pkgs.streamdeck-ui];
        home.sessionVariables.STREAMDECK_UI_CONFIG = "${config.xdg.configHome}/streamdeck-ui/config.json";
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
