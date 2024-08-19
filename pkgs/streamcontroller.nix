{
  stdenv,
  lib,
  python3Packages,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  wrapGAppsHook4,
  gobject-introspection,
  libadwaita,
  libportal,
  libportal-gtk4,
  xdg-desktop-portal,
  xdg-desktop-portal-gtk,
}:
let
  streamcontroller-plugin-tools = python3Packages.buildPythonPackage rec {
    pname = "streamcontroller-plugin-tools";
    version = "2.0.0";

    src = fetchFromGitHub {
      owner = "StreamController";
      repo = "streamcontroller-plugin-tools";
      rev = version;
      hash = "sha256-dQZPRSzHhI3X+Pf7miwJlECGFgUfp68PtvwXAmpq5/s=";
    };

    dependencies = with python3Packages; [
      loguru
      rpyc
    ];

    pythonImportsCheck = [ "streamcontroller_plugin_tools" ];

    meta = with lib; {
      description = "StreamController plugin tools";
      homepage = "https://github.com/StreamController/streamcontroller-plugin-tools";
      license = licenses.gpl3;
      maintainers = with maintainers; [ sifmelcara ];
      platforms = lib.platforms.linux;
    };
  };
in
stdenv.mkDerivation rec {
  name = "streamcontroller";

  # Note that the latest tagged version (1.5.0-beta.6) includes a python dependency
  # that doesn't exist anymore, so we package an unstable version instead.
  version = "0-unstable-2024-08-13";

  src = fetchFromGitHub {
    repo = "StreamController";
    owner = "StreamController";
    rev = "dbb6460a69137af192db09d504224ae9f1127cbd";
    hash = "sha256-+YYzHLRU5MNjF3iaKIDj9k4PVg+vnEZhbc3ZmNI7xyw=";
  };

  # The installation method documented upstream
  # (https://streamcontroller.github.io/docs/latest/installation/) is to clone the repo,
  # run `pip install`, then run `python3 main.py` to launch the program.
  # Due to how the code is structured upstream, it's infeasible to use `buildPythonApplication`.

  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/

    cat << EOF > $out/bin/streamcontroller
    #!/usr/bin/env bash

    # Note that the implementation of main.py assumes
    # working directory to be at the root of the project's source code
    cd ${src}
    ${python3Packages.python}/bin/python main.py

    EOF
    chmod +x $out/bin/streamcontroller

    wrapProgram $out/bin/streamcontroller --prefix PYTHONPATH : "$PYTHONPATH"

    # Install udev rules
    mkdir -p "$out/etc/udev/rules.d"
    cp ${src}/udev.rules $out/etc/udev/rules.d/70-streamcontroller.rules

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "StreamController";
      desktopName = "StreamController";
      exec = "streamcontroller";
      icon = "${src}/flatpak/icon_256.png";
      categories = [ "Application" ];
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook4
  ];

  buildInputs =
    [
      gobject-introspection
      libadwaita
      libportal
      libportal-gtk4
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ]
    ++ (with python3Packages; [
      annotated-types
      async-lru
      cairocffi
      cairosvg
      certifi
      cffi
      charset-normalizer
      click
      colorama
      contourpy
      cssselect2
      cycler
      dbus-python
      decorator
      defusedxml
      distlib
      dnspython
      evdev
      filelock
      fonttools
      fuzzywuzzy
      gcodepy
      get-video-properties
      gitdb
      idna
      imageio
      imageio-ffmpeg
      indexed-bzip2
      jinja2
      joblib
      kiwisolver
      levenshtein
      linkify-it-py
      loguru
      markdown-it-py
      markupsafe
      matplotlib
      mdit-py-plugins
      mdurl
      meson
      meson-python
      natsort
      nltk
      numpy
      opencv4
      packaging
      pillow
      platformdirs
      plumbum
      proglog
      psutil
      pulsectl
      pycairo
      pyclip
      pycparser
      pydantic
      pydantic-core
      pyenchant
      pygments
      pygobject3
      pymongo
      pyparsing
      pyperclip
      pyproject-metadata
      pyro5
      pyspellchecker
      python-dateutil
      pyudev
      pyusb
      pyyaml
      rapidfuzz
      regex
      requests
      requirements-parser
      rich
      rpyc
      serpent
      setproctitle
      setproctitle
      six
      smmap
      speedtest-cli
      streamcontroller-plugin-tools
      streamdeck
      textual
      tinycss2
      tqdm
      types-setuptools
      typing-extensions
      uc-micro-py
      urllib3
      usb-monitor
      webencodings
      websocket-client
    ]);

  meta = with lib; {
    description = "An elegant Linux app for the Elgato Stream Deck with support for plugins";
    homepage = "https://core447.com/";
    license = licenses.gpl3;
    mainProgram = "streamcontroller";
    maintainers = with maintainers; [ sifmelcara ];
    platforms = lib.platforms.linux;
  };
}
