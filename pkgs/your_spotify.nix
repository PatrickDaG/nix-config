{
  mkYarnPackage,
  fetchFromGitHub,
  fetchYarnDeps,
  makeWrapper,
  nodejs,
  yarn,
  prefetch-yarn-deps,
  lib,
  callPackage,
}: let
  version = "1.8.0";
  src = fetchFromGitHub {
    owner = "Yooooomi";
    repo = "your_spotify";
    rev = "refs/tags/${version}";
    hash = "sha256-umm7J5ADY2fl+tjs6Qeda5MX2P55u0eCqwW+DWLK8Kc=";
  };
  client = callPackage ./your_spotify_client.nix {inherit src version;};
in
  mkYarnPackage rec {
    inherit version src;
    pname = "your_spotify";
    offlineCache = fetchYarnDeps {
      yarnLock = src + "/yarn.lock";
      hash = "sha256-pj6owoEPx9gdtFvXF8E89A+Thhe/7m0+OJU6Ttc6ooA=";
    };

    configurePhase = ''
      runHook preConfigure

      export HOME=$(mktemp -d)
      yarn config --offline set yarn-offline-mirror $offlineCache
      fixup-yarn-lock yarn.lock
      yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
      patchShebangs node_modules/

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      ls -lah
      pushd ./apps/server/
      yarn --offline run build
      popd
      runHook postBuild
    '';
    nativeBuildInputs = [makeWrapper yarn prefetch-yarn-deps];
    installPhase = ''
      mkdir -p $out
      cp -r node_modules $out/node_modules
      cp -r ./apps/server/{lib,package.json} $out
      mkdir -p $out/bin
      makeWrapper ${lib.escapeShellArg (lib.getExe nodejs)} "$out/bin/your_spotify_migrate" \
        --add-flags "$out/lib/migrations.js"
      makeWrapper ${lib.escapeShellArg (lib.getExe nodejs)} "$out/bin/your_spotify_server" \
        --add-flags "$out/lib/index.js"
    '';
    doDist = false;
    passthru = {
      inherit client;
    };
  }
