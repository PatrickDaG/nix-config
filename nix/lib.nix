{
  self,
  nixpkgs,
  ...
}: {
  # some programs( such as steam do not work with bindmounts
  # additionally symlinks are a lot faster than bindmounts
  # ~ 2x faster in my tests
  impermanence.makeSymlinks = builtins.map (x: {
    directory = x;
    method = "symlink";
  });
}
