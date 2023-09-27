{config, ...}: {
  programs.streamdeck-ui = {
    enable = true;
    settings = {
      # Device ID
      "AL31H1B01852" = {
        buttons = {
          # Page number
          "0" = {
            # button number
            "5" = {
              # keyInput to press
              keys = "F7";
              # Text shown on button
              #text = "mute";
              icon = config.images.images."mic.png";
              # Text position
              text_vertical_align = "middle-bottom";
            };
            "6" = {
              keys = "F8";
              text = "deafen";
              text_vertical_align = "middle-bottom";
            };
          };
        };
        brightness = 99; # brighness value between 0 and 99
        display_timeout = 0; # dimmer timeout in seconds
        brightness_dimmed = 99; # dimmed brighness
      };
    };
  };
}
