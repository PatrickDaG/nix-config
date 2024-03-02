{
  mkYarnPackage,
  makeWrapper,
  fetchYarnDeps,
  apiEndpoint ? "localhost:8080",
  src_o,
  version,
}:
mkYarnPackage rec {
  inherit version;
  pname = "your_spotify_client";
  src = "${src_o}/client";
  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-9UfRVv7M9311lesnr19oThYnzB9cK23XNZejJY/Fd24=";
  };
  postPatch = ''
    substituteInPlace tsconfig.json --replace-quiet '"extends": "../tsconfig.json",' ""
  '';
  buildPhase = ''
    runHook preBuild
    pushd ./deps/client_ts
    yarn --offline run build
    popd
    runHook postBuild
  '';
  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    mkdir -p $out
    cp -r ./deps/client_ts/build/* $out
    substituteInPlace $out/variables-template.js --replace-quiet '__API_ENDPOINT__' "${apiEndpoint}"
    mv $out/variables-template.js $out/variables.js
  '';
  doDist = false;
}
