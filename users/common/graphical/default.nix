{
  pkgs,
  config,
  ...
}: {
  imports = [
    #./deadd
    ./themes.nix
  ];
  home = {
    packages = with pkgs; [
      zathura
      pinentry
      feh
      mpv
    ];
  };

  # notification are nice to have
  services.dunst = {
    enable = true;
    settings.global = {
      frame_width = 0;
      highlight = config.lib.stylix.colors.withHashtag.base0C;
      progress_bar_frame_width = 0;
      progress_bar_corner_radius = 0;
    };
  };
}
