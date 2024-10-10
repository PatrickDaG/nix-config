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
  version = "24.10.1";

  src = fetchFromGitHub {
    owner = "actualbudget";
    repo = "actual-server";
    rev = "v${version}";
    hash = "sha256-VJAD+lNamwuYmiPJLXkum6piGi5zLOHBp8cUeZagb4s=";
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
    outputHash = "sha256-siq3JnM0FFmXj5iX48E1A8X0lbdHM9NNCjOcg0Pwg5I=";
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
    description = "A super fast privacy-focused app for managing your finances";
    homepage = "https://actualbudget.com/";
    license = licenses.mit;
    mainProgram = "actual-server";
    maintainers = with maintainers; [ patrickdag ];
    platforms = [ "x86_64-linux" ];
  };
}
