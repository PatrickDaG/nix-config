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
    rev = "71547ae3abbfd331a890ca2d5f3572bd92c0cecc";
    hash = "sha256-Nq60EQz2TINtA4rkUsgVE4rvZ5O9otD8GXWJYPkiAhs=";
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
