{
  stdenv,
  fetchFromGitHub,
  sqlite,
}:
stdenv.mkDerivation {
  name = "zsh-histdb";
  src = fetchFromGitHub {
    owner = "larkery";
    repo = "zsh-histdb";
    rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
    hash = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
  };
  patchPhase = ''
    substituteInPlace "sqlite-history.zsh" "histdb-migrate" "histdb-merge" \
    --replace-fail "sqlite3" "${sqlite}/bin/sqlite3"
  '';
  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
