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
    rev = "1be91285705bfdb55656db0835820cb034fe5010";
    hash = "sha256-lPhp3Jq6YM8fi0WS/fJrCHdfdQFs5vdErdE5X80WAHE=";
  };

  cargoHash = "sha256-9bhKtg2g5H4zGn7yVCjTazeXfeoKjtAKAlzkLkCraiw=";

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
