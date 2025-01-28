{
  fetchurl,
  google-chrome,
  lib,
  makeDesktopItem,
  runtimeShell,
  symlinkJoin,
  writeScriptBin,

  # command line arguments which are always set e.g "--disable-gpu"
  commandLineArgs ? [ ],
}:

let
  name = "amazon-prime-via-google-chrome";

  meta = {
    description = "Open amazon-prime in Google Chrome app mode";
    longDescription = ''
      amazon-prime is a video streaming service providing films, TV series and exclusive content. See https://www.amazon-prime.com.

      This package installs an application launcher item that opens amazon-prime in a dedicated Google Chrome window. If your preferred browser doesn't support amazon-prime's DRM, this package provides a quick and easy way to launch DisneyPlus on a supported browser, without polluting your application list with a redundant, single-purpose browser.
    '';
    homepage = google-chrome.meta.homepage or null;
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.patrickdag ];
    platforms = google-chrome.meta.platforms or lib.platforms.all;
  };

  desktopItem = makeDesktopItem {
    inherit name;
    # Executing by name as opposed to store path is conventional and prevents
    # copies of the desktop file from bitrotting too much.
    # (e.g. a copy in ~/.config/autostart, you lazy lazy bastard ;) )
    exec = name;
    icon = fetchurl {
      name = "disneyplus-logo-2024.jpg";
      url = "https://lumiere-a.akamaihd.net/v1/images/disney_logo_march_2024_050fef2e.png?region=0%2C0%2C1920%2C1080";
      sha256 = "sha256-t71veeGtr3LF3Rzf47YFY7j9XEYmxW/Ob6eluJx1skE=";
      meta.license = lib.licenses.unfree;
    };
    desktopName = "amazon-prime via Google Chrome";
    genericName = "A video streaming service providing films and exclusive TV series";
    categories = [
      "TV"
      "AudioVideo"
      "Network"
    ];
    startupNotify = true;
  };

  script = writeScriptBin name ''
    #!${runtimeShell}
    exec ${google-chrome}/bin/${google-chrome.meta.mainProgram} ${lib.escapeShellArgs commandLineArgs} \
      --app=https://www.amazon.com \
      --no-first-run \
      --no-default-browser-check \
      --no-crash-upload \
      --user-data-dir=$HOME/.config/amazon-prime \
      "$@"
  '';

in

symlinkJoin {
  inherit name meta;
  paths = [
    script
    desktopItem
  ];
}
