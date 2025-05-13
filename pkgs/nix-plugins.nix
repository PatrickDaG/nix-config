{
  lib,
  stdenv,
  fetchFromGitHub,
  nix,
  cmake,
  pkg-config,
  capnproto,
  boost,
}:

stdenv.mkDerivation rec {
  pname = "nix-plugins";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "patrickdag";
    repo = "nix-plugins";
    rev = "c85627e50bf92807091321029fca3f700c3f13e2";
    hash = "sha256-lfQ+tDrNj8+nMw1mUl4ombjxdRpIKmAvcimxN4n1Iyo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    nix
    boost
    capnproto
  ];

  meta = {
    description = "Collection of miscellaneous plugins for the nix expression language";
    homepage = "https://github.com/shlevy/nix-plugins";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
