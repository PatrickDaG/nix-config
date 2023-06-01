{
  config,
  lib,
  pkgs,
  ...
}:
with lib.lists; {
  home.persistence."/state/home/${config.home.username}" = {
    allowOther = true;
    files = [
      ".ssh/known_hosts"
    ];
    directories =
      optionals config.programs.atuin.enable [
        ".local/share/atuin"
      ]
      ++ optionals config.programs.firefox.enable [
        ".mozilla"
      ]
      ++ optionals config.programs.neovim.enable [
        ".local/share/nvim"
        ".local/state/nvim"
        ".cache/nvim"
      ]
      ++ optionals config.programs.direnv.enable [
        ".local/share/direnv"
      ]
      ++ optionals (builtins.elem pkgs.nextcloud-client config.home.packages) [
        "./Nextcloud"
        ".config/Nextcloud"
      ];
  };
}
