{ config, pkgs, ... }:
{
  stylix.targets = {
    #keep-sorted start
    bat.enable = true;
    btop.enable = true;
    font-packages.enable = true;
    fontconfig.enable = true;
    fzf.enable = true;
    ghostty.enable = true;
    gitui.enable = true;
    gtk.enable = true;
    hyprland.enable = true;
    mpv.enable = true;
    starship.enable = true;
    swaync.enable = true;
    waybar.enable = true;
    xresources.enable = true;
    zathura.enable = true;
    #keep-sorted end
  };

  xresources.properties = {
    "Xft.hinting" = true;
    "Xft.antialias" = true;
    "Xft.autohint" = false;
    "Xft.lcdfilter" = "lcddefault";
    "Xft.hintstyle" = "hintfull";
    "Xft.rgba" = "rgb";
  };

  gtk =
    let
      gtk34extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-cursor-theme-size = 18;
        gtk-enable-animations = true;
        gtk-xft-antialias = 1;
        gtk-xft-dpi = 96; # XXX: delete for wayland?
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintfull";
        gtk-xft-rgba = "rgb";
      };
    in
    {
      enable = true;
      iconTheme = {
        name = "Vimix-Doder";
        package = pkgs.vimix-icon-theme;
      };

      gtk2.extraConfig = "gtk-application-prefer-dark-theme = true";
      gtk3.extraConfig = gtk34extraConfig;
      gtk4.extraConfig = gtk34extraConfig;
    };

  home.sessionVariables.GTK_THEME = config.gtk.theme.name;

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "Adwaita-Dark";
  };
}
