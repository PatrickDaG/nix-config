{
  mkYarnPackage,
  fetchFromGitHub,
  fetchYarnDeps,
  makeWrapper,
  nodejs,
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
    buildPhase = ''
      runHook preBuild
      pushd ./deps/@your_spotify/root/apps/server/
      yarn --offline --production
      popd
      runHook postBuild
    '';
    nativeBuildInputs = [makeWrapper];
    installPhase = ''
      mkdir -p $out
      cp -r $node_modules $out/node_modules
      cp -r ./deps/your_spotify/apps/server/{lib,package.json} $out
      mkdir -p $out/bin
      makeWrapper ${lib.escapeShellArg (lib.getExe nodejs)} "$out/bin/your_spotify_migrate" \
        --add-flags "$out/lib/migrations.js"
      makeWrapper ${lib.escapeShellArg (lib.getExe nodejs)} "$out/bin/your_spotify_server" \
        --add-flags "$out/lib/bin/www.js"
    '';
    doDist = false;
    passthru = {
      inherit client;
    };
  }
