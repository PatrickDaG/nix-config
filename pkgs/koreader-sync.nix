{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  zip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "koreader-sync";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "kyxap";
    repo = "koreader-calibre-plugin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GIk4Sk/44gnWZb+zcfNgq+fGvORP604fPC7DcWYJWNE=";
  };

  nativeBuildInputs = [ zip ];

  buildPhase = ''
    runHook preBuild
    make build
    runHook postBuild
  '';

  installPhase = ''
    install -Dm444 "dist/KOReader_Sync_v${finalAttrs.version}.zip" "$out/KOReader_Sync_v${finalAttrs.version}.zip"
  '';

  meta = {
    description = "Calibre plugin for synchronizing KOReader metadata";
    homepage = "https://github.com/kyxap/koreader-calibre-plugin";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ patrickdag ];
    platforms = lib.platforms.all;
  };
})
