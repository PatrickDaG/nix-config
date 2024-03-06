{
  mkYarnPackage,
  makeWrapper,
  fetchYarnDeps,
  apiEndpoint ? "localhost:8080",
  src,
  version,
  yarn,
  prefetch-yarn-deps,
}:
mkYarnPackage rec {
  inherit version src;
  pname = "your_spotify_client";
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
    pushd ./apps/client/
    pwd
    yarn --offline run build
    popd
    runHook postBuild
  '';
  nativeBuildInputs = [makeWrapper yarn prefetch-yarn-deps];

  installPhase = ''
    mkdir -p $out
    cp -r ./apps/client/build/* $out
    substituteInPlace $out/variables-template.js --replace-quiet '__API_ENDPOINT__' "${apiEndpoint}"
    mv $out/variables-template.js $out/variables.js
  '';
  doDist = false;
}
