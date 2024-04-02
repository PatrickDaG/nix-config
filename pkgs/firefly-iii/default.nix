{
  pkgs,
  stdenv,
  lib,
  fetchFromGitHub,
  dataDir ? "/var/lib/firefly-iii",
}: let
  version = "6.1.13";
  src = fetchFromGitHub {
    owner = "firefly-iii";
    repo = "firefly-iii";
    rev = "v${version}";
    hash = "sha256-85zI8uCyyoCflzxDkvba6FWa9B3kh179DJfQ2Um6MGM=";
  };

  package =
    (import ./compose2nix.nix {
      inherit pkgs;
      inherit (stdenv.hostPlatform) system;
      noDev = true;
      php = pkgs.php83;
      phpPackages = pkgs.php83Packages;
    })
    .overrideAttrs (oldAttrs: {
      installPhase =
        oldAttrs.installPhase
        + ''
          rm -R $out/storage
          ln -s ${dataDir}/storage $out/storage
          ln -fs ${dataDir}/.env $out/.env
        '';
    });
in
  package.override rec {
    inherit src version;
    pname = "firefly-iii";

    meta = with lib; {
      description = "Firefly III: a personal finances manager";
      homepage = "https://github.com/firefly-iii/firefly-iii/";
      changelog = "https://github.com/firefly-iii/firefly-iii/releases/tag/v${version}";
      license = licenses.agpl3Only;
      maintainers = with maintainers; [patrickdag];
      mainProgram = "firefly-iii";
      platforms = platforms.all;
    };
  }
