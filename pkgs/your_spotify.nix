{
  mkYarnPackage,
  fetchFromGitHub,
  fetchYarnDeps,
  makeWrapper,
  nodejs,
  lib,
  callPackage,
}: let
  version = "1.7.3";
  src_o = fetchFromGitHub {
    owner = "Yooooomi";
    repo = "your_spotify";
    rev = "refs/tags/${version}";
    hash = "sha256-/0xKktywwGcqsuwLytWBJ3O6ADHg1nP6BdMRlkW5ErY=";
  };
  client = callPackage ./your_spotify_client.nix {inherit src_o version;};
in
  mkYarnPackage rec {
    inherit version;
    pname = "your_spotify";
    src = "${src_o}/server";
    offlineCache = fetchYarnDeps {
      yarnLock = src + "/yarn.lock";
      hash = "sha256-3ZK+p3RoHHjPu53MLGSho7lEroZ77vUrZ2CjDwIUQTs=";
    };
    postPatch = ''
      substituteInPlace tsconfig.json --replace-quiet '"extends": "../tsconfig.json",' ""
    '';
    buildPhase = ''
      runHook preBuild
      pushd ./deps/server
      yarn --offline run build
      popd
      runHook postBuild
    '';
    nativeBuildInputs = [makeWrapper];
    installPhase = ''
      mkdir -p $out
      cp -r $node_modules $out/node_modules
      cp -r ./deps/server/{lib,package.json} $out
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
