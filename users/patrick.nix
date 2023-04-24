{
  config,
  pkgs,
  ...
}: {
  imports = [
    common/programs/kitty.nix
    common/graphical/hyprland.nix
    #common/programs/polybar.nix
    common/programs/rofi.nix
    #common/programs/spotify.nix
    #common/graphical/herbstluftwm.nix
    #common/graphical/autorandr.nix
    #common/touchegg-module.nix
    #common/touchegg-settings.nix
  ];

  home = {
    packages = with pkgs; [
      thunderbird
      discord
      bitwarden
      nextcloud-client
      signal-desktop
      chromium
      xdragon
      xournalpp
      zathura
      pinentry
      arandr
      feh
      xclip
      acpilight
    ];
    sessionVariables = {
      # Firefox touch support
      "MOZ_USE_XINPUT2" = 1;
      # Firefox Hardware render
      "MOZ_WEBRENDER" = 1;
    };
  };

  programs.firefox = {
    enable = true;
    profiles.patrick = {
      userChrome = ''
        #TabsToolbar {
        visibility: collapse;
        }

        #titlebar {
            margin-bottom: !important;
        }

        #titlebar-buttonbox {
            height: 32px !important;
        }
      '';
    };
  };

  # notification are nice to have
  services.dunst.enable = true;

  nixpkgs.config.allowUnfree = true;
  xsession.enable = true;
}
