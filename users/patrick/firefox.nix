{pkgs, ...}: {
  programs.firefox = let
    betterfox = pkgs.fetchFromGitHub {
      owner = "yokoffing";
      repo = "Betterfox";
      rev = "116.1";
      hash = "sha256-Ai8Szbrk/4FhGhS4r5gA2DqjALFRfQKo2a/TwWCIA6g=";
    };
  in {
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
      extraConfig = builtins.concatStringsSep "\n" [
        (builtins.readFile "${betterfox}/Securefox.js")
        (builtins.readFile "${betterfox}/Fastfox.js")
        (builtins.readFile "${betterfox}/Peskyfox.js")
      ];
      settings = {
        # user chrome soll funzen
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # nvidia hardware video decode
        # https:#github.com/elFarto/nvidia-vaapi-driver
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        # enable if grapics card support av1
        "media.av1.enabled" = false;
        "widget.dmabuf.force-enabled" = true;
        # General
        "browser.toolbars.bookmarks.visibility" = "never"; # Never show the bookmark toolbar
        "intl.accept_languages" = "en-US,en";
        "browser.startup.page" = 3; # always resume session on restart
        "privacy.clearOnShutdown.history" = false; # persist history pls
        "devtools.chrome.enabled" = true; # enable js in the dev console
        "browser.tabs.crashReporting.sendReport" = false; # don't send crash reports
        "accessibility.typeaheadfind.enablesound" = false; # No sound in search windows pls
        "general.autoScroll" = true;
        "browser.translations.automaticallyPopup" = false;
        "browser.translations.neverTranslateLanguages" = "de";

        # Privacy
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
        # Firefox shall not test option changes on me pls
        "app.normandy.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;

        "beacon.enabled" = false;
        "device.sensors.enabled" = false;
        "geo.enabled" = false;
        # enable ech
        "network.dns.echconfig.enabled" = true;
        #disable all telemetry
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.enabled" = false; # enforced by nixos
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.unified" = false;
        "extensions.webcompat-reporter.enabled" = false; # don't report compability problems to mozilla
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.urlbar.eventTelemetry.enabled" = false; # (default)
        # no firefox passwd manager
        "browser.contentblocking.report.lockwise.enabled" = false;
        "browser.uitour.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        # no encrypted media extension pls
        "media.eme.enabled" = false;
        "browser.eme.ui.enabled" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "dom.battery.enabled" = false; # no battery for you
      };
      search = {
        force = true;
        default = "kagi";

        engines = {
          "Bing".metaData.hidden = true;
          "Amazon.com".metaData.hidden = true;
          "Google".metaData.hidden = true;

          "kagi" = {
            iconUpdateURL = "https://kagi.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000; # update every day
            urls = [
              {
                template = "https://kagi.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
        };
      };
    };
  };
}
