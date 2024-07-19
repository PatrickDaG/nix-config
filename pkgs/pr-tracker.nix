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
    rev = "4cd2e8216f8c98441c74a883833ee73123fb1042";
    hash = "sha256-OOohIvqPsCBtMXbg3D3GUdZYsTR13YPyWERGPCGZwa4=";
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
