{
  lib,
  stdenv,
  fetchFromGitHub,
  nix,
  cmake,
  pkg-config,
  boost,
}:

stdenv.mkDerivation rec {
  pname = "nix-plugins";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "patrickdag";
    repo = "nix-plugins";
    rev = "1ae8d0c7faa187c388bdebc54ed05c9722d26f11";
    hash = "sha256-+IKZyjpDlDJVVm/wg03XpS6w0NdwIoFPFHNJ55WvAsI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    nix
    boost
  ];

  meta = {
    description = "Collection of miscellaneous plugins for the nix expression language";
    homepage = "https://github.com/shlevy/nix-plugins";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
