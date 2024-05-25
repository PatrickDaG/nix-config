{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "homebox-frontend";
  version = "0.10.3";

  src = "${fetchFromGitHub {
    owner = "hay-kot";
    repo = "homebox";
    rev = "v${version}";
    hash = "sha256-nPMc7H8AcHnHGNn9g0xuI2TqMQPCmUBfqV/5KMdpxWU=";
  }}/frontend";

  env.CYPRESS_INSTALL_BINARY = "0";
  npmDepsHash = "sha256-xnRBfVc/ZPRSDAe35hvXtrxnqv9/COuA0oV36n/sPTA=";

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';

  installPhase = ''
    runHook preInstall

    ls -la

    runHook postInstall
  '';

  meta = with lib; {
  };
}
