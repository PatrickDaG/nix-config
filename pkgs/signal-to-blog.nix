{ rustPlatform, fetchgit }:
rustPlatform.buildRustPackage {
  name = "signal-to-blog";

  src = fetchgit {
    url = "https://forge.lel.lol/patrick/signal-to-blog.git";
    rev = "5e7a42d386a76f23affcb3d58b54dd41e96844ec";
    hash = "sha256-MBKLx67Ivsk7E/6H75xj8zpeXzG+zXGBsEfHzn10YHk=";
  };

  cargoHash = "sha256-q9r1VeRQ5HOmBdst58MgS+hdyEXHIdncqV1v3OTmQv8=";
  meta.mainProgram = "signal-to-blog";

}
