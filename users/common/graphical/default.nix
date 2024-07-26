{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      zathura
      feh
      mpv
      pinentry-gnome3 # for yubikey pinentry
    ];
  };

  # notification are nice to have
  services.dunst = {
    enable = true;
    settings.global = {
      monitor = 1;
      frame_width = 0;
      highlight = config.lib.stylix.colors.withHashtag.base0C;
      progress_bar_frame_width = 0;
      progress_bar_corner_radius = 0;
    };
  };
}
