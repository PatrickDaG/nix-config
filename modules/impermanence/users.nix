userName: {
  config,
  lib,
  ...
}: {
  environment.persistence."/state" = {
    users.${userName} = let
      hmConfig = config.home-manager.users.${userName};
    in {
      files = [
        ".ssh/known_hosts"
      ];
      directories = with lib.lists;
        []
        ++
        # firefox cannot be a symlink as home manager refuses put files outside your $HOME
        optionals hmConfig.programs.firefox.enable [
          ".mozilla"
        ]
        ++ optionals hmConfig.programs.atuin.enable [
          ".local/share/atuin"
        ]
        ++ optionals hmConfig.programs.direnv.enable [
          ".local/share/direnv"
        ]
        ++ optionals hmConfig.programs.neovim.enable [
          ".local/share/nvim"
          ".local/state/nvim"
          ".cache/nvim"
        ]
        # root should never use interactive programs
        ++ optionals config.services.pipewire.enable [
          # persist sound config
          ".local/state/wireplumber"
        ]
        # Folders for steam
        ++ optionals config.programs.steam.enable
        [
          ".local/share/Steam"
          ".steam"
          ".local/share//Daedalic Entertainment GmbH/"
        ];
    };
  };
}
