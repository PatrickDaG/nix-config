{ rustPlatform, fetchgit, }:
rustPlatform.buildRustPackage {
  name = "signal-to-blog";

  src = fetchgit {
    url = "https://forge.lel.lol/patrick/signal-to-blog.git";
    rev = "b2c44e90030b1333e20012641904080def43b6dd";
    hash = "sha256-H846+65ImZqbUHt91xc8GCcNszXMnvTi+4jAs+JYLLA=";
  };

  cargoHash = "sha256-0LLSxVpql6bFoSS3hsns5JuptJCmn4LxKjG7clPDrm8=";

}
