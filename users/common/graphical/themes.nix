{
  pkgs,
  config,
  lib,
  ...
}: {
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.openzone-cursors;
    name = "OpenZone_White_Slim";
    size = 18;
  };

  stylix = {
    targets = {
      gtk.enable = true;
      bat.enable = true;
      dunst.enable = true;
      zathura.enable = true;
      xresources.enable = true;
    };
  };

  xresources.properties = {
    "Xft.hinting" = true;
    "Xft.antialias" = true;
    "Xft.autohint" = false;
    "Xft.lcdfilter" = "lcddefault";
    "Xft.hintstyle" = "hintfull";
    "Xft.rgba" = "rgb";
  };

  gtk = let
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
  in {
    enable = true;
    iconTheme = {
      name = "Vimix-Doder";
      package = pkgs.vimix-icon-theme;
    };

    theme = lib.mkForce {
      name = "Orchis-purple-solid-black";
      package = pkgs.orchis-theme;
    };

    gtk2.extraConfig = "gtk-application-prefer-dark-theme = true";
    gtk3.extraConfig = gtk34extraConfig;
    gtk4.extraConfig = gtk34extraConfig;
  };

  home.sessionVariables.GTK_THEME = config.gtk.theme.name;

  qt = {
    enable = true;
    platformTheme = "gtk";
  };
}
