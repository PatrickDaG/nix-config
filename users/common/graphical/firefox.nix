{
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
  xdg.mimeApps.enable = true;
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
        # https:#github.com/elFarto/nvidia-vaapi-driver
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        # enable if grapics card support av1
        "media.av1.enabled" = false;
        "widget.dmabuf.force-enabled" = true;
        # Speeeeed
        # Betterfox/
        # PREF: initial paint delay
        # How long FF will wait before rendering the page, in milliseconds
        # Reduce the 5ms Firefox waits to render the page
        # [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1283302
        # [2] https://docs.google.com/document/d/1BvCoZzk2_rNZx3u9ESPoFjSADRI0zIPeJRXFLwWXx_4/edit#heading=h.28ki6m8dg30z
        "nglayout.initialpaint.delay" = 0; # default=5; used to be 250
        "nglayout.initialpaint.delay_in_oopif" = 0; # default=5

        # PREF: use bigger packets
        # Reduce Firefox's CPU usage by requiring fewer application-to-driver data transfers.
        # However, it does not affect the actual packet sizes transmitted over the network.
        # [1] https://www.mail-archive.com/support-seamonkey@lists.mozilla.org/msg74561.html
        "network.buffer.cache.size" = 262144; # 256 kb; default=32768 (32 kb
        "network.buffer.cache.count" = 128; # default=24

        # PREF: increase the absolute number of HTTP connections
        # [1] https://kb.mozillazine.org/Network.http.max-connections
        # [2] https://kb.mozillazine.org/Network.http.max-persistent-connections-per-server
        # [3] https://www.reddit.com/r/firefox/comments/11m2yuh/how_do_i_make_firefox_use_more_of_my_900_megabit/jbfmru6/
        "network.http.max-connections" = 1800; # default=900
        "network.http.max-persistent-connections-per-server" = 10; # default=6; download connections; anything above 10 is excessive
        "network.http.max-urgent-start-excessive-connections-per-host" = 5; # default=3
        #"network.http.max-persistent-connections-per-proxy" = 48; // default=32
        "network.websocket.max-connections" = 400; # default=200

        # PREF: preferred color scheme for websites
        # [SETTING] General>Language and Appearance>Website appearance
        # By default, color scheme matches the theme of your browser toolbar (3).
        # Set this pref to choose Dark on sites that support it (0) or Light (1).
        # Before FF95, the pref was 2, which determined site color based on OS theme.
        # Dark (0), Light (1), System (2), Browser (3) (default [FF95+])
        # [1] https://www.reddit.com/r/firefox/comments/rfj6yc/how_to_stop_firefoxs_dark_theme_from_overriding/hoe82i5/?context=3
        "layout.css.prefers-color-scheme.content-override" = 0;

        # PREF: disable annoying update restart prompts
        # Delay update available prompts for ~1 week.
        # Will still show green arrow in menu bar.
        "app.update.suppressPrompts" = true;

        # PREF: Mozilla VPN
        # [1] https://github.com/yokoffing/Betterfox/issues/169
        "browser.privatebrowsing.vpnpromourl" = "";
        #"browser.vpn_promo.enabled" = false;

        # PREF: disable about:addons' Recommendations pane (uses Google Analytics)
        "extensions.getAddons.showPane" = false; # HIDDEN
        "extensions.htmlaboutaddons.recommendations.enabled" = false;

        # PREF: disable Extension Recommendations (CFR: "Contextual Feature Recommender")
        # [1] https://support.mozilla.org/en-US/kb/extension-recommendations
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

        # PREF: hide "More from Mozilla" in Settings
        "browser.preferences.moreFromMozilla" = false;

        # PREF: Warnings
        "browser.aboutConfig.showWarning" = false;

        # PREF: disable fullscreen delay and notice
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.warning.delay" = -1;
        "full-screen-api.warning.timeout" = 0;

        # PREF: minimize URL bar suggestions (bookmarks, history, open tabs)
        "browser.urlbar.suggest.engines" = false;

        # PREF: enable helpful features:
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.unitConversion.enabled" = true;

        # PREF: Disable built-in Pocket extension
        "extensions.pocket.enabled" = false;

        # PREF: open PDFs inline (FF103+)
        "browser.download.open_pdf_attachments_inline" = true;

        # PREF: PDF sidebar on load [HIDDEN]
        # 2=table of contents (if not available, will default to 1)
        # 1=view pages
        # -1=disabled (default)
        "pdfjs.sidebarViewOnLoad" = 2;

        "browser.contentblocking.category" = "strict";

        # PREF: enable Global Privacy Control (GPC) [NIGHTLY]
        # Honored by many highly ranked sites [2].
        # [TEST] https://global-privacy-control.glitch.me/
        # [1] https://globalprivacycontrol.org/press-release/20201007.html
        # [2] https://github.com/arkenfox/user.js/issues/1542#issuecomment-1279823954
        # [3] https://blog.mozilla.org/netpolicy/2021/10/28/implementing-global-privacy-control/
        # [4] https://help.duckduckgo.com/duckduckgo-help-pages/privacy/gpc/
        # [5] https://brave.com/web-standards-at-brave/4-global-privacy-control/
        # [6] https://www.eff.org/gpc-privacy-badger
        # [7] https://www.eff.org/issues/do-not-track
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.functionality.enabled" = true;

        # PREF: enable advanced fingerprinting protection
        # [WARNING] Leave disabled unless you're okay with all the drawbacks
        # [1] https://librewolf.net/docs/faq/#what-are-the-most-common-downsides-of-rfp-resist-fingerprinting
        # [2] https://www.reddit.com/r/firefox/comments/wuqpgi/comment/ile3whx/?context=3
        "privacy.resistFingerprinting" = true;

        # PREF: enable seperate search engine for Private Windows
        # [SETTINGS] Preferences>Search>Default Search Engine>"Use this search engine in Private Windows"
        "browser.search.separatePrivateDefault.ui.enabled" = true;

        # PREF: disable search and form history
        # Be aware that autocomplete form data can be read by third parties [1][2].
        # Form data can easily be stolen by third parties.
        # [SETTING] Privacy & Security>History>Custom Settings>Remember search and form history
        # [1] https://blog.mindedsecurity.com/2011/10/autocompleteagain.html
        # [2] https://bugzilla.mozilla.org/381681
        "browser.formfill.enable" = false;

        # PREF: Enforce Punycode for Internationalized Domain Names to eliminate possible spoofing
        # Firefox has some protections, but it is better to be safe than sorry.
        # [!] Might be undesirable for non-latin alphabet users since legitimate IDN's are also punycoded.
        # [TEST] https://www.xn--80ak6aa92e.com/ (www.apple.com)
        # [1] https://wiki.mozilla.org/IDN_Display_Algorithm
        # [2] https://en.wikipedia.org/wiki/IDN_homograph_attack
        # [3] CVE-2017-5383: https://www.mozilla.org/security/advisories/mfsa2017-02/
        # [4] https://www.xudongz.com/blog/2017/idn-phishing/
        "network.IDN_show_punycode" = true;

        # PREF: enable HTTPS-only Mode
        "dom.security.https_only_mode" = true; # Normal + Private Browsing windows

        # PREF: disable password manager
        # [NOTE] This does not clear any passwords already saved.
        "signon.rememberSignons" = false; # Privacy & Security>Logins and Passwords>Ask to save logins and passwords for websites

        # PREF: disable form autofill
        # [NOTE] stored data is not secure (uses a JSON file)
        # [1] https://wiki.mozilla.org/Firefox/Features/Form_Autofill
        # [2] https://www.ghacks.net/2017/05/24/firefoxs-new-form-autofill-is-awesome
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # PREF: prevent accessibility services from accessing your browser [RESTART]
        # Accessibility Service may negatively impact Firefox browsing performance.
        # Disable it if you’re not using any type of physical impairment assistive software.
        # [1] https://support.mozilla.org/kb/accessibility-services
        # [2] https://www.ghacks.net/2021/08/25/firefox-tip-turn-off-accessibility-services-to-improve-performance/
        # [3] https://www.reddit.com/r/firefox/comments/p8g5zd/why_does_disabling_accessibility_services_improve
        # [4] https://winaero.com/firefox-has-accessibility-service-memory-leak-you-should-disable-it/
        # [5] https://www.ghacks.net/2022/12/26/firefoxs-accessibility-performance-is-getting-a-huge-boost/
        "accessibility.force_disabled" = 1;

        # PREF: disable Firefox View [FF106+]
        # [1] https://support.mozilla.org/en-US/kb/how-set-tab-pickup-firefox-view#w_what-is-firefox-view
        "browser.tabs.firefox-view" = false;

        # PREF: default permission for Web Notifications
        # To add site exceptions: Page Info>Permissions>Receive Notifications
        # To manage site exceptions: Options>Privacy & Security>Permissions>Notifications>Settings
        # 0=always ask (default), 1=allow, 2=block
        "permissions.default.desktop-notification" = 2;

        # PREF: default permission for Location Requests
        # 0=always ask (default), 1=allow, 2=block
        "permissions.default.geo" = 2;

        # Disable all the various Mozilla telemetry, studies, reports, etc.

        # PREF: Telemetry
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.dap_enabled" = false; # DEFAULT [FF108]

        # PREF: Telemetry Coverage
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;

        # PREF: Health Reports
        # [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to send technical data.
        "datareporting.healthreport.uploadEnabled" = false;

        # PREF: new data submission, master kill switch
        # If disabled, no policy is shown or upload takes place, ever
        # [1] https://bugzilla.mozilla.org/1195552
        "datareporting.policy.dataSubmissionEnabled" = false;

        # PREF: Studies
        # [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to install and run studies
        "app.shield.optoutstudies.enabled" = false;

        # Personalized Extension Recommendations in about:addons and AMO
        # [NOTE] This pref has no effect when Health Reports are disabled.
        # [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to make personalized extension recommendations
        "browser.discovery.enabled" = false;

        # PREF: disable crash reports
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        # PREF: enforce no submission of backlogged crash reports
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

        # PREF: software that continually reports what default browser you are using [WINDOWS]
        # [WARNING] Breaks "Make Default..." button in Preferences to set Firefox as the default browser [2].
        # [1] https://techdows.com/2020/04/what-is-firefox-default-browser-agent-and-how-to-disable-it.html
        # [2] https://github.com/yokoffing/Betterfox/issues/166
        "default-browser-agent.enabled" = false;

        # PREF: "report extensions for abuse"
        "extensions.abuseReport.enabled" = false;

        # PREF: Normandy/Shield [extensions tracking]
        # Shield is an telemetry system (including Heartbeat) that can also push and test "recipes"
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";

        # PREF: PingCentre telemetry (used in several System Add-ons)
        # Currently blocked by 'datareporting.healthreport.uploadEnabled'
        "browser.ping-centre.telemetry" = false;

        # PREF: disable Firefox Home (Activity Stream) telemetry
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;

        # privacy is mir auch wichtig
      };
    };
  };
}
