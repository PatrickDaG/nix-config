{
  rustPlatform,
  sqlite,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "zsh-histd-skim";
  version = "0.8.6";
  buildInputs = [ sqlite ];
  src = fetchFromGitHub {
    owner = "m42e";
    repo = "zsh-histdb-skim";
    rev = "v${version}";
    hash = "sha256-lJ2kpIXPHE8qP0EBnLuyvatWMtepBobNAC09e7itGas=";
  };
  cargoHash = "sha256-dqTYJkKnvjzkV124XZHzDV58rjLhNz+Nc3Jj5gSaJas=";
  postInstall = ''
    substituteInPlace zsh-histdb-skim-vendored.zsh \
    --replace-fail "zsh-histdb-skim" "$out/bin/zsh-histdb-skim"
    cp zsh-histdb-skim-vendored.zsh $out/zsh-histdb-skim.plugin.zsh
  '';
}
