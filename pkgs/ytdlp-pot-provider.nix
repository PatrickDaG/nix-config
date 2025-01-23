{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bgutil-ytdlp-pot-provider";
  version = "0.7.2";

  src = "${
    fetchFromGitHub {
      owner = "Brainicism";
      repo = "bgutil-ytdlp-pot-provider";
      tag = finalAttrs.version;
      hash = "sha256-IiPle9hZEHFG6bjMbe+psVJH0iBZXOMg3pjgoERH3Eg=";
    }
  }/server";

  offlineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-2LCzURu1rcchu4i/xLEiQojEwirQAdbXePfHAJczQMk=";
  };

  nativeBuildInputs = [
    makeWrapper
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  buildPhase = ''
    runHook preBuild
    npx tsc
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/ytdlp-pot-provider
    cp -r node_modules $out/share/ytdlp-pot-provider/node_modules
    cp -r build $out/lib/
    cp -r package.json $out/

    mkdir -p $out/bin
    makeWrapper ${lib.escapeShellArg (lib.getExe nodejs)} "$out/bin/serve" \
      --add-flags "$out/lib/main.js" --set NODE_PATH "$out/share/ytdlp-pot-provider/node_modules"
    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ patrickdag ];
  };
})
