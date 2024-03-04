{
  mkYarnPackage,
  makeWrapper,
  fetchYarnDeps,
  apiEndpoint ? "localhost:8080",
  src,
  version,
}:
mkYarnPackage rec {
  inherit version src;
  pname = "your_spotify_client";
  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-pj6owoEPx9gdtFvXF8E89A+Thhe/7m0+OJU6Ttc6ooA=";
  };
  buildPhase = ''
    runHook preBuild
    pushd ./deps/@your_spotify/root/apps/client/
    pwd
    yarn --offline run build
    popd
    runHook postBuild
  '';
  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    mkdir -p $out
    cp -r ./deps/your_spotify/apps/client/build/* $out
    substituteInPlace $out/variables-template.js --replace-quiet '__API_ENDPOINT__' "${apiEndpoint}"
    mv $out/variables-template.js $out/variables.js
  '';
  doDist = false;
}
