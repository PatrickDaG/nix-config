{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "goldfish";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "sameoldlab";
    repo = "goldfish";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+FlRwwtLFlzxcgtkdD47G/yrqYKgzo0pWKH1RIBli8A=";
  };
  cargoHash = "sha256-OJEw436p+P1dW1JSxX1EbyuDJBf4fMbHhpmavrbzTsw=";

  meta = {
    description = "goldfish (`gf`) is a IPC file finder.";
    homepage = "https://github.com/sameoldlab/goldfish";
    license = lib.licenses.mpl20;
    mainProgram = "goldfish";
  };
})
