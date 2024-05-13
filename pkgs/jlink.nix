{
  stdenv,
  lib,
  requireFile,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  fontconfig,
  freetype,
  libICE,
  libSM,
  udev,
  libX11,
  libXext,
  libXcursor,
  libXfixes,
  libXrender,
  libXrandr,
}: let
  version = "796f";
  url = "https://www.segger.com/downloads/jlink/JLink_Linux_V${version}_x86_64.tgz";
  hash = "02ahzj6dwxh15bnk2468zidi78vyiyp9v3bkq7rfijmasl73ybhr";
  archiveFilename = "JLink_Linux_V${version}_x86_64.tgz";
in
  stdenv.mkDerivation {
    pname = "j-link";
    inherit version;

    src = requireFile {
      name = archiveFilename;
      url = "https://www.segger.com/downloads/jlink#J-LinkSoftwareAndDocumentationPack";
      sha256 = hash;
    };

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    preferLocalBuild = true;

    nativeBuildInputs = [copyDesktopItems autoPatchelfHook makeWrapper];

    buildInputs = [
      udev
      stdenv.cc.cc.lib
      fontconfig
      freetype
      libICE
      libSM
      libX11
      libXext
      libXcursor
      libXfixes
      libXrender
      libXrandr
    ];

    runtimeDependencies = [udev];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib/JLink" "$out/share/doc" "$out/bin"

      cp -R * "$out/lib/JLink"
      rm "$out/lib/JLink/99-jlink.rules"

      for f in "$out/lib/JLink"/J*; do
          if [[ -L $f ]]; then
              mv "$f" "$out/bin/"
          elif [[ -x $f ]]; then
              makeWrapper "$f" "$out/bin/$(basename "$f")"
          fi
      done

      mv "$out/lib/JLink/Doc" "$out/share/doc/JLink"
      mv \
          "$out/lib/JLink"/README* \
          "$out/lib/JLink/Samples" \
          "$out/lib/JLink/GDBServer"/Readme* \
          "$out/share/doc/JLink/"

      install -D -t "$out/lib/udev/rules.d" 99-jlink.rules

      runHook postInstall
    '';

    preFixup = ''
      patchelf --add-needed libudev.so.1 $out/lib/JLink/libjlinkarm.so
    '';

    meta = with lib; {
      homepage = "https://www.segger.com/downloads/jlink";
      description = "SEGGER J-Link";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = with maintainers; [liff];
      mainProgram = "JLinkExe";
    };
  }
