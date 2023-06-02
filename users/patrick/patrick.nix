{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../common/programs/kitty.nix
    ../common/graphical/hyprland.nix
    ../common/programs/rofi.nix
    ../common/devshell.nix
    ./ssh.nix
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
      feh
      acpilight
      galaxy-buds-client
      netflix
    ];
    sessionVariables = {
      # Firefox touch support
      "MOZ_USE_XINPUT2" = 1;
      # Firefox Hardware render
      "MOZ_WEBRENDER" = 1;
    };

    persistence."/state/home/${config.home.username}" = let
      # some programs( such as steam do not work with bindmounts
      # additionally symlinks are a lot faster than bindmounts
      # ~ 2x faster in my tests
      makeSymLinks = x:
        builtins.map (x: {
          directory = x;
          method = "symlink";
        })
        x;
    in {
      directories =
        [
          "repos"
          "Downloads"

          # persist sound config
          ".local/state/wireplumber"
        ]
        ++ makeSymLinks [
          ".local/share/Steam"
          ".steam"
          ".local/share//Daedalic Entertainment GmbH/The Pillars of the Earth/"
        ];
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
}
