{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      spotify-tui
    ];
  };
  services.spotifyd = {
    enable = true;
    # TODO
    # This seems to need a spoticy login to correctly work
    # And even then its most likely only spoty as the
    # network play function of spotify is kinda bad
  };
}
