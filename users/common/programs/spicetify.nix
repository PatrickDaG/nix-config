{spicePkgs, ...}: {
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.RetroBlur;
    colorScheme = "Purple";

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle # shuffle+ (special characters are sanitized out of ext names)
      hidePodcasts
      popupLyrics
      fullAlbumDate
      skipStats
      showQueueDuration
      history
      volumePercentage
    ];
  };
}
