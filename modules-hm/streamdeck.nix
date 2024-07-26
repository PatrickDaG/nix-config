{ lib, pkgs, ... }:
let
  inherit (lib)
    types
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    ;
  settingsFormat = pkgs.formats.json { };
in
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      let
        cfg = settingsFormat.generate "config.json" {
          streamdeck_ui_version = 2;
          state = config.programs.streamdeck-ui.settings;
        };
        preStart = pkgs.writeShellScript "streamdeck-setup-config" ''
          ${pkgs.coreutils}/bin/cp "${cfg}" "$XDG_RUNTIME_DIR/streamdeck/config.json"
        '';
      in
      {
        options.programs.streamdeck-ui = {
          enable = mkEnableOption "streamdeck-ui";
          package = mkPackageOption pkgs "streamdeck-ui" { };
          settings = mkOption {
            default = { };
            type = types.submodule { freeformType = settingsFormat.type; };
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
                  ConditionEnvironment = [ "DISPLAY" ];
                };
                Service = {
                  Type = "exec";
                  ExecStart = "${pkgs.streamdeck-ui}/bin/streamdeck --no-ui";
                  ExecStartPre = preStart;
                  Environment = ''STREAMDECK_UI_CONFIG=%t/streamdeck/config.json'';
                  RuntimeDirectory = "streamdeck";
                };
                Install.WantedBy = [ "graphical-session.target" ];
              };
            };
          };
        };
      }
    )
  ];
}
