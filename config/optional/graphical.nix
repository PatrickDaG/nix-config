{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.hidpi = mkOption {
    default = false;
    type = types.bool;
    description = "Enable HighDPI configuration for this host and all installed users";
  };

  # stylix acceses stylix options on import meaning you can only import this module when you're actually setting stylix options
  imports = [ inputs.stylix.nixosModules.stylix ];

  config = {
    environment.systemPackages = with pkgs; [ xdg-utils ];
    xdg.portal = {
      xdgOpenUsePortal = true;
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      config = {
        common.default = [
          "gtk"
          "hyprland"
        ];
        sway.default = [ "wlr" ];
      };
    };
    # needed for gnome pinentry
    services.dbus.packages = [ pkgs.gcr ];
    fonts = {
      enableGhostscriptFonts = false;
      fontDir.enable = false;
      fontconfig = {
        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
              <alias binding="weak">
                  <family>monospace</family>
                  <prefer>
                      <family>emoji</family>
                  </prefer>
              </alias>
              <alias binding="weak">
                  <family>sans-serif</family>
                  <prefer>
                      <family>emoji</family>
                  </prefer>
              </alias>
              <alias binding="weak">
                  <family>serif</family>
                  <prefer>
                      <family>emoji</family>
                  </prefer>
              </alias>
          </fontconfig>
        '';
      };
      packages = with pkgs; [
        (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
        ibm-plex
        dejavu_fonts
        unifont
        freefont_ttf
        gyre-fonts # TrueType substitutes for standard PostScript fonts
        liberation_ttf
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        noto-fonts-extra
      ];
    };
    stylix.fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "IBM Plex Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "IBM Plex Sans";
      };

      monospace = {
        # No need for patched nerd fonts, kitty can pick up on them automatically,
        # and ideally every program should do that: https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
    stylix = {
      enable = true;
      autoEnable = false;
      polarity = "dark";
      image = config.lib.stylix.pixel "base00";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/vice.yaml";
      # Has to be green
      override.base0B = "#00CC99";
      #base16Scheme = {
      #	base00 = "#101419";
      #	base01 = "#171B20";
      #	base02 = "#21262e";
      #	base03 = "#242931";
      #	base04 = "#485263";
      #	base05 = "#b6beca";
      #	base06 = "#dee1e6";
      #	base07 = "#e3e6eb";
      #	base08 = "#e05f65";
      #	base09 = "#f9a872";
      #	base0A = "#f1cf8a";
      #	base0B = "#78dba9";
      #	base0C = "#74bee9";
      #	base0D = "#70a5eb";
      #	base0E = "#c68aee";
      #	base0F = "#9378de";
      #};
      ## based on decaycs-dark, bright variant
      #base16Scheme = {
      #  base00 = "#101419";
      #  base01 = "#171B20";
      #  base02 = "#21262e";
      #  base03 = "#242931";
      #  base04 = "#485263";
      #  base05 = "#b6beca";
      #  base06 = "#dee1e6";
      #  base07 = "#e3e6eb";
      #  base08 = "#e5646a";
      #  base09 = "#f7b77c";
      #  base0A = "#f6d48f";
      #  base0B = "#94F7C5";
      #  base0C = "#79c3ee";
      #  base0D = "#75aaf0";
      #  base0E = "#cb8ff3";
      #  base0F = "#9d85e1";
      #};
    };

    home-manager.sharedModules = [
      (
        {
          pkgs,
          config,
          nixosConfig,
          ...
        }:
        {
          stylix = {
            cursor = {
              package = pkgs.openzone-cursors;
              name = "OpenZone_White_Slim";
              size = if nixosConfig.hidpi then 48 else 18;
            };
            inherit (nixosConfig.stylix) polarity;
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
      )
    ];
  };
}
