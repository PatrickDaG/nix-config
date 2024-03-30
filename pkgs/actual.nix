{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  cacert,
  gitMinimal,
  nodejs,
  yarn,
}:
stdenv.mkDerivation rec {
  pname = "actual-server";
  version = "24.3.0";

  src = fetchFromGitHub {
    owner = "actualbudget";
    repo = "actual-server";
    rev = "v${version}";
    hash = "sha256-y51Dhdn84AWR/gM4LnAzvBIBpvKwUiclnPnwzkRoJ0I=";
  };
  # we cannot use fetchYarnDeps because that doesn't support yarn 2/berry lockfiles
  offlineCache = stdenv.mkDerivation {
    name = "actual-server-${version}-offline-cache";
    inherit src;

    nativeBuildInputs = [
      cacert # needed for git
      gitMinimal # needed to download git dependencies
      yarn
    ];

    buildPhase = ''
      export HOME=$(mktemp -d)
      yarn config set enableTelemetry 0
      yarn config set cacheFolder $out
      yarn config set --json supportedArchitectures.os '[ "linux" ]'
      yarn config set --json supportedArchitectures.cpu '[ "x64" ]'
      yarn
    '';

    installPhase = ''
      mkdir -p $out
      cp -r ./node_modules $out/node_modules
    '';
    dontFixup = true;

    outputHashMode = "recursive";
    outputHash = "sha256-ViIIk7l+m0k0K7AaZ6cnCFc7SVNPzW6hPRdEfceO5mc=";
  };

  nativeBuildInputs = [
    makeWrapper
    yarn
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ${offlineCache}/node_modules/ $out/
    cp -r ./ $out

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} "$out/bin/actual-server" \
      --add-flags "$out/app.js" --set NODE_PATH "$out/node_modules" \

    runHook postInstall
  '';

  meta = with lib; {
  };
}
