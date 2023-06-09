{
  pkgs,
  config,
  lib,
  nixosConfig,
  extraLib,
  ...
}: {
  home.persistence."/state/${config.home.homeDirectory}" = with lib.lists; {
    allowOther = true;
    files = [
      ".ssh/known_hosts"
    ];
    directories =
      # firefox cannot be a symlink as home manager refuses put files outside your $HOME
      optionals config.programs.firefox.enable [
        ".mozilla"
      ]
      ++ extraLib.impermanence.makeSymlinks (
        optionals config.programs.atuin.enable [
          ".local/share/atuin"
        ]
        ++ optionals config.programs.direnv.enable [
          ".local/share/direnv"
        ]
        ++ optionals config.programs.neovim.enable [
          ".local/share/nvim"
          ".local/state/nvim"
          ".cache/nvim"
        ]
        ++ optionals (builtins.elem pkgs.heroic config.home.packages) [
          ".config/heroic"
          "Games/Heroic"
        ]
        # root should never use interactive programs
        ++ optionals nixosConfig.users.users.${config.home.username}.isNormalUser (
          optionals nixosConfig.services.pipewire.enable [
            # persist sound config
            ".local/state/wireplumber"
          ]
          # Folders for steam
          ++ optionals nixosConfig.programs.steam.enable
          [
            ".local/share/Steam"
            ".steam"
            ".local/share//Daedalic Entertainment GmbH/"
          ]
        )
      );
  };
}
