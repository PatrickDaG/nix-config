{
  rustPlatform,
  lib,
  openssl,
  pkg-config,
  systemd,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  name = "pr-tracker";

  src = fetchFromGitHub {
    owner = "patrickdag";
    repo = "pr-tracker";
    rev = "54d47f277df81bfe82339ec3d2ceabd9c371aa91";
    hash = "sha256-C3dGaxxEH2acM1Ozvk5BcU+Gq6vPjSEzBVWZcRKMSzk=";
  };

  cargoHash = "sha256-pcIbL/mWhvQpQcVgyeNccW5cnHGKPKBpY9f2eeSrcjk=";

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl systemd];

  meta = with lib; {
    description = "Nixpkgs pull request channel tracker";
    longDescription = ''
      A web server that displays the path a Nixpkgs pull request will take
      through the various release channels.
    '';
    platforms = platforms.linux;
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [patrickdag];
    mainProgram = "pr-tracker";
  };
}
