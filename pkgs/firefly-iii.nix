{
  lib,
  dataDir ? "/var/lib/firefly-iii",
  php83,
  fetchFromGitHub,
  buildNpmPackage,
}: let
  version = "6.1.13";
  src = fetchFromGitHub {
    owner = "firefly-iii";
    repo = "firefly-iii";
    rev = "v${version}";
    hash = "sha256-85zI8uCyyoCflzxDkvba6FWa9B3kh179DJfQ2Um6MGM=";
  };
  frontend = buildNpmPackage {
    inherit src version;
    pname = "firefly-iii";
    npmDepsHash = "sha256-wuPUE6XuzzgKjpxZVgwh2wGut15M61WSBFG+YIZwOFM=";
    installPhase = ''
      mkdir -p $out
      rm -rf ./node_modules
      cp -r ./ $out
      mkdir -p $out/storage
      cp -r ./ $out
      rm -Rf $out/storage
      ln -fs ${dataDir}/storage $out/storage
      rm -Rf $out/bootstrap/cache
      ln -fs ${dataDir}/bootstrap/cache $out/bootstrap/cache
    '';
  };
in
  php83.buildComposerProject rec {
    inherit version;
    src = frontend;
    pname = "firefly-iii";
    vendorHash = "sha256-CVGKyyLp5hjjpEulDNEYfljU4OgPBaFcYQQAUf6GeGs=";

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
