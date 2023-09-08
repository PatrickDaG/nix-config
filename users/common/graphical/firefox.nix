{
  config,
  pkgs,
  ...
}: let
  inherit
    (pkgs)
    fetchFromGitHub
    ;
  inherit
    (builtins)
    readFile
    ;
in {
  home = {
    sessionVariables = {
      # Firefox touch support
      MOZ_USE_XINPUT2 = 1;
      # Firefox Hardware render
      MOZ_WEBRENDER = 1;
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      MOZ_DISABLE_RDD_SANDBOX = 1;
    };
  };
  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
  programs.firefox = {
    enable = true;
    profiles.patrick = {
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
      settings = {
        # user chrome soll funzen
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # nvidia hardware video decode
        # https://github.com/elFarto/nvidia-vaapi-driver
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        # enable if grapics card support av1
        "media.av1.enabled" = false;
        "widget.dmabuf.force-enabled" = true;
        # privacy is mir auch wichtig
      };
    };
  };
}
