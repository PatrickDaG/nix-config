{
  ensureNewerSourcesForZipFilesHook,
  fetchFromGitHub,
  lib,
  python3,
  stdenvNoCC,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dedrm";
  version = "10.0.3";

  src = fetchFromGitHub {
    owner = "noDRM";
    repo = "DeDRM_tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BqRcN7ItZdB4d1MOLzsDXCruViyTOt395x/kJLHxOIs=";
  };

  nativeBuildInputs = [
    ensureNewerSourcesForZipFilesHook
    python3
    unzip
  ];

  buildPhase = ''
    runHook preBuild

    python3 ./make_release.py
    unzip DeDRM_tools.zip -d plugin

    runHook postBuild
  '';

  installPhase = ''
    install -Dm444 plugin/DeDRM_plugin.zip "$out/DeDRM_plugin.zip"
  '';

  meta = {
    description = "Calibre plugin for removing DRM from ebooks";
    homepage = "https://github.com/noDRM/DeDRM_tools";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ patrickdag ];
    platforms = lib.platforms.all;
  };
})
