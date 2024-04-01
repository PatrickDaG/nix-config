{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "firefly-iii";
  version = "6.1.13";

  src = fetchFromGitHub {
    owner = "firefly-iii";
    repo = "firefly-iii";
    rev = "v${version}";
    hash = "sha256-85zI8uCyyoCflzxDkvba6FWa9B3kh179DJfQ2Um6MGM=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/
    cp -R . $out/
    runHook postInstall
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
