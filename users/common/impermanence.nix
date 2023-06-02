{
  config,
  lib,
  nixosConfig,
  ...
}: {
  home.persistence."/state/${config.home.homeDirectory}" = with lib.lists; {
    allowOther = true;
    files = [
      ".ssh/known_hosts"
    ];
    directories = let
      # some programs( such as steam do not work with bindmounts
      # additionally symlinks are a lot faster than bindmounts
      # ~ 2x faster in my tests
      makeSymLinks = x:
        builtins.map (x: {
          directory = x;
          method = "symlink";
        })
        x;
    in
      # firefox cannot be a symlink as home manager refuses put files outside your $HOME
      optionals config.programs.firefox.enable [
        ".mozilla"
      ]
      ++ makeSymLinks (
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
        # root should never use interactive programs
        ++ optionals nixosConfig.users.users.${config.home.username}.isNormalUser (
          optionals nixosConfig.services.pipewire.enable [
            # persist sound config
            ".local/state/wireplumber"
          ]
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
