{ config, ... }:
{
  programs.streamdeck-ui = {
    #enable = true;
    settings = {
      # Device ID
      "AL31H1B01852" = {
        # fuck you streamdeck?
        # why no distinction between settings and state????
        rotation = 0;
        buttons = {
          # Page number
          "0" = {
            # button number
            "5" = {
              state = 0;
              states = {
                "0" = {
                  # keyInput to press
                  keys = "ctrl+F7";
                  # Text shown on button
                  #text = "mute";
                  icon = config.images.images."mic.png";
                  # Text position
                  text_vertical_align = "middle-bottom";
                  background_color = "#7289DA";
                };
              };
            };
            "0" = {
              state = 0;
              states = {
                "0" = {
                  keys = "ctrl+F9";
                  icon = config.images.images."wallpaper.png";
                  background_color = "#7289DA";
                };
              };
            };
            "6" = {
              state = 0;
              states = {
                "0" = {
                  keys = "ctrl+F8";
                  icon = config.images.images."heads.png";
                  background_color = "#7289DA";
                };
              };
            };
            "14" = {
              state = 0;
              states = {
                "0" = {
                  keys = "cmd+F12";
                  icon = config.images.images."screenshot.png";
                  text_vertical_align = "middle";
                  background_color = config.lib.stylix.colors.withHashtag.base09;
                };
              };
            };
            "9" = {
              state = 0;
              states = {
                "0" = {
                  keys = "cmd+F11";
                  icon = config.images.images."screenshot.png";
                  text = "SAVE";
                  text_vertical_align = "middle";
                  font = "${config.stylix.fonts.serif.package}/share/fonts/truetype/DejaVuSerif.ttf";
                  background_color = config.lib.stylix.colors.withHashtag.base09;
                };
              };
            };
            "4" = {
              state = 0;
              states = {
                "0" = {
                  keys = "cmd+F10";
                  icon = config.images.images."screenshot.png";
                  text = "QR";
                  text_vertical_align = "middle";
                  background_color = config.lib.stylix.colors.withHashtag.base09;
                };
              };
            };
            "3" = {
              state = 0;
              states = {
                "0" = {
                  keys = "cmd+F9";
                  icon = config.images.images."screenshot.png";
                  text = "OCR";
                  text_vertical_align = "middle";
                  background_color = config.lib.stylix.colors.withHashtag.base09;
                };
              };
            };
            "13" = {
              state = 0;
              states = {
                "0" = {
                  icon = config.images.images."player.png";
                  switch_page = 2;
                };
              };
            };
          };
          "1" = {
            "0" = {
              state = 0;
              states = {
                "0" = {
                  icon = config.images.images."back.png";
                  switch_page = 1;
                  background_color = config.lib.stylix.colors.withHashtag.base0C;
                };
              };
            };
          };
        };
        page = 0; # The startup page
        brightness = 99; # brighness value between 0 and 99
        display_timeout = 0; # dimmer timeout in seconds
        brightness_dimmed = 99; # dimmed brighness
      };
    };
  };
}
