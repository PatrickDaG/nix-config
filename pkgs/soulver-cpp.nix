{
  lib,
  fetchFromGitHub,
  stdenv,
  swift,
  cmake,
}:
stdenv.mkDerivation (_finalAttrs: {
  pname = "solver-cpp";
  version = "unstable-2026-01-16";
  buildInputs = [
    swift
    cmake
  ];

  src = fetchFromGitHub {
    owner = "vicinaehq";
    repo = "soulver-cpp";
    rev = "cff4fda07abe1056ee7464f8d5d8dfc2c09389e4";
    hash = "sha256-/1PA3IUZK1Wi8ienJsBnqrcry8LR8RvU5ruLwdZeAKk=";
  };
})
