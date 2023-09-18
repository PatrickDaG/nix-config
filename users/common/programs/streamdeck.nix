{
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
              text = "mute";
              # Text position
              text_vertical_align = "middle-bottom";
            };
            "6" = {
              keys = "F8";
              text = "deafen";
              text_vertical_align = "top";
            };
            "7" = {
              # background picture
              icon = "/home/patrick/ms.jpg";
              # command to execute on press
              command = "echo lol";
              # background fill colour
              background_color = "#000000";
            };
          };
        };
        brightness = 99; # brighness value between 0 and 99
        display_timeout = 1800; # dimmer timeout in seconds
        brightness_dimmed = 10; # dimmed brighness
      };
    };
  };
}
