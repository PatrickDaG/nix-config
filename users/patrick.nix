{
  config,
  pkgs,
  ...
}: {
  imports = [
    common/programs/kitty.nix
    common/graphical/herbstluftwm.nix
    common/graphical/autorandr.nix
    common/programs/polybar.nix
    common/programs/rofi.nix
    common/touchegg-module.nix
    common/touchegg-settings.nix
  ];

  home = {
    stateVersion = "23.05";
    packages = with pkgs; [
      thunderbird
      discord
      bitwarden
      nextcloud-client
      signal-desktop
      spotify
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
      search.default = "DuckDuckGo";
      search.force = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
  xsession.enable = true;
}
