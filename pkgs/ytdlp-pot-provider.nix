{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,
  makeWrapper,
  callPackage,
  nixosTests,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bgutil-ytdlp-pot-provider";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "Brainicism";
    repo = "bgutil-ytdlp-pot-provider";
    tag = finalAttrs.version;
    hash = "";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/server/yarn.lock";
    hash = "";
  };

  nativeBuildInputs = [
    makeWrapper
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  buildPhase = ''
    pushd ./server/
    npx tsc
    popd
  '';

  installPhase = ''
    runHook preInstall
  '';

  meta = {
    homepage = "https://github.com/Yooooomi/your_spotify";
    changelog = "https://github.com/Yooooomi/your_spotify/releases/tag/${finalAttrs.version}";
    description = "Self-hosted application that tracks what you listen and offers you a dashboard to explore statistics about it";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ patrickdag ];
  };
})
