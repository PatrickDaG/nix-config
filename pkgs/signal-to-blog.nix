{ rustPlatform, fetchgit }:
rustPlatform.buildRustPackage {
  name = "signal-to-blog";

  src = fetchgit {
    url = "https://forge.lel.lol/patrick/signal-to-blog.git";
    rev = "280acaa8b03fb15d84ba594f1dd7f5c28aa1c2c1";
    hash = "sha256-ZoQUlR+qsBE9AP8s1kh5KyGmtWQQ0KSYakaxgUegSZ4=";
  };

  cargoHash = "sha256-q9r1VeRQ5HOmBdst58MgS+hdyEXHIdncqV1v3OTmQv8=";
  meta.mainProgram = "signal-to-blog";

}
