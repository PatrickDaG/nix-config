{config, ...}: {
  home = {
    sessionVariables = {
      # Firefox touch support
      "MOZ_USE_XINPUT2" = 1;
      # Firefox Hardware render
      "MOZ_WEBRENDER" = 1;
    };
  };
  programs.firefox = {
    enable = true;
    profiles.patrick = {
      # For this to work you need to enable about:config
      # toolkit.legacyUserProfileCustomizations.stylesheets = true
      userChrome = ''
        #TabsToolbar {
        visibility: collapse;
        }

        #titlebar {
            margin-bottom: !important;
        }

        #titlebar-buttonbox {
            height: 32px !important;
        }
      '';
    };
  };
}
