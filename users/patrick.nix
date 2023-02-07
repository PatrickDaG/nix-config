{
  config,
  pkgs,
  ...
}: {
  imports = [
    common/kitty.nix
    common/herbstluftwm.nix
    common/autorandr.nix
    common/desktop.nix
    common/polybar.nix
    ./common
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
    ];
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
