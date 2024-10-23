{ rustPlatform, fetchgit }:
rustPlatform.buildRustPackage {
  name = "signal-to-blog";

  src = fetchgit {
    url = "https://forge.lel.lol/patrick/signal-to-blog.git";
    rev = "bdb7c803d2185ca1d5cd11d21f3606eef34b0555";
    hash = "sha256-mcgP1u+a63W+gbvIpz0uXqwcd2AOKC+VcDpK0mV6GIg=";
  };

  cargoHash = "sha256-q9r1VeRQ5HOmBdst58MgS+hdyEXHIdncqV1v3OTmQv8=";
  meta.mainProgram = "signal-to-blog";

}
