{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.deadd-notification-center;
  inherit
    (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    literalExpression
    mkIf
    types
    ;

  settingsFormat = pkgs.formats.yaml {};
in {
  options.services.deadd-notification-center = {
    enable = mkEnableOption "deadd notification center";

    package = mkPackageOption pkgs "deadd-notification-center" {};

    settings = mkOption {
      default = {};
      type = types.submodule {
        freeformType = settingsFormat.type;
      };
      description = ''
        Settings for the notification center.
        More information about the settings can be found on the project's homepage.
      '';
      example = literalExpression ''
        {
          notification-center = {
            marginTop = 30;
            width = 500;
          };
          notification-center-notification-popup = {
            width = 300;
            shortenBody = 3;
          };
        }
      '';
    };

    style = mkOption {
      type = types.lines;
      description = "CSS styling for notifications.";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."deadd/deadd.yml".source = settingsFormat.generate "deadd.yml" cfg.settings;

    xdg.configFile."deadd/deadd.css".text = cfg.style;

    systemd.user.services.deadd-notification-center = {
      Unit = {
        Description = "Deadd Notification Center";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        X-Restart-Triggers = ["${config.xdg.configFile."deadd/deadd.yml".source}" "${config.xdg.configFile."deadd/deadd.css".source}"];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${cfg.package}/bin/deadd-notification-center";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
