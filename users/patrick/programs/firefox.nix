{ lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep escapeShellArg mapAttrsToList;
  env = {
    MOZ_WEBRENDER = 1;
    # For a better scrolling implementation and touch support.
    # Be sure to also disable "Use smooth scrolling" in about:preferences
    MOZ_USE_XINPUT2 = 1;
    # Required for hardware video decoding.
    # See https://github.com/elFarto/nvidia-vaapi-driver?tab=readme-ov-file#firefox
    MOZ_DISABLE_RDD_SANDBOX = 1;
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };
  envStr = concatStringsSep " " (mapAttrsToList (n: v: "${n}=${escapeShellArg v}") env);
in
{
  hm.home.persistence."/state".directories = [
    ".cache/mozilla"
    ".mozilla"
  ];
  hm.xdg.mimeApps.enable = true;
  hm.xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
  hm.programs.firefox =
    let
      betterfox = pkgs.fetchFromGitHub {
        owner = "yokoffing";
        repo = "Betterfox";
        rev = "142.0";
        hash = "sha256-3xvZAMPdGfj8w2AaepWW5xAX05Ry+pN8peLMORKNTIc=";
      };
    in
    {
      enable = true;
      package =
        (pkgs.firefox.overrideAttrs (old: {
          buildCommand = old.buildCommand + ''
            substituteInPlace $out/bin/firefox \
              --replace "exec -a" ${escapeShellArg envStr}" exec -a"
          '';
        })).override
          {
            nativeMessagingHosts = [
              pkgs.tridactyl-native
            ];
          };
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
          "gfx.webrender.all" = true;
          "media.rdd-ffmpeg.enabled" = true;
          "gfx.x11-egl.force-enabled" = true;
          # enable if grapics card support av1
          # invidious kinda depends on av1
          "media.av1.enabled" = true;
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
          "dom.private-attribution.submission.enabled" = false; # No PPA for me pls
        };
        search = {
          force = true;
          default = "kagi";

          engines = {
            "bing".metaData.hidden = true;
            "amazondotcom-us".metaData.hidden = true;
            "google".metaData.hidden = true;

            "kagi" = {
              icon = "https://kagi.com/favicon.ico";
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
