{ config, lib, ... }:
{
  hm = {
    stylix.targets.swaync.enable = true;

    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";

        layer = "overlay";
        layer-shell = true;
        cssPriority = "application";

        control-center-layer = "top";
        control-center-width = 800;
        control-center-height = 1600;
        control-center-margin-top = 0;
        control-center-margin-bottom = 0;
        control-center-margin-right = 0;
        control-center-margin-left = 0;

        notification-window-width = 500;
        notification-2fa-action = true;
        notification-inline-replies = false;
        notification-icon-size = 64;
        notification-body-image-height = 100;
        notification-body-image-width = 200;

        keyboard-shortcuts = true;
        image-visibility = "when-available";
        transition-time = 100;

        widgets = [
          "inhibitors"
          "dnd"
          "mpris"
          "notifications"
        ];

        widget-config = {
          inhibitors = {
            text = "Inhibitors";
            button-text = "Clear All";
            clear-all-button = true;
          };
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "Clear All";
          };
          dnd = {
            text = "Do Not Disturb";
          };
          label = {
            max-lines = 5;
            text = "Label Text";
          };
          mpris = {
            image-size = 96;
            blur = true;
          };
        };
      };
    };
  };
}
