{
  stdenv,
  lib,
  fetchurl,
  dataDir ? "/var/lib/firefly-iii",
}: let
  version = "6.1.13";
  src = fetchurl {
    url = "https://github.com/firefly-iii/firefly-iii/releases/download/v${version}/FireflyIII-v${version}.tar.gz";
    hash = "sha256-uQzk3pgdZ0baqmBouHfcuzrymwrsDy6b4IwSY3br6f0=";
  };
in
  stdenv.mkDerivation rec {
    inherit src version;
    pname = "firefly-iii";
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/storage
      cp -r ./ $out
      rm -R $out/storage
      #ln -fs ${dataDir}/storage $out/storage
      #ln -fs ${dataDir}/bootstrap/cache $out/bootstrap/cache
      #ln -fs ${dataDir}/.env $out/.env
    '';

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
