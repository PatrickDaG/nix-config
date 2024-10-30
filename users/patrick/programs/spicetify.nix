{ inputs, pkgs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  hm.programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.retroBlur;
    colorScheme = "Purple";

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle # shuffle+ (special characters are sanitized out of ext names)
      hidePodcasts
      fullAlbumDate
      skipStats
      history
    ];
  };
}
