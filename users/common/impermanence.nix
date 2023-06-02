{
  config,
  lib,
  nixosConfig,
  ...
}: {
  home.persistence."/state/home/${config.home.username}" = with lib.lists; {
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
      ++ optionals config.programs.firefox.enable [
        ".mozilla"
        # root should never use interactive programs
      ]
      ++ optionals (config.home.username != "root") (
        optionals nixosConfig.services.pipewire.enable [
          # persist sound config
          ".local/state/wireplumber"
        ]
        ++ optionals nixosConfig.programs.steam.enable
        (makeSymLinks [
          ".local/share/Steam"
          ".steam"
          ".local/share//Daedalic Entertainment GmbH/The Pillars of the Earth/"
        ])
      );
  };
}
