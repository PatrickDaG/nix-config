{
  config,
  lib,
  ...
}: {
  home.persistence."/state" = {
    files = with lib.lists;
      [
        ".ssh/known_hosts"
        ".cache/fuzzel"
      ]
      ++ optionals config.programs.rofi.enable [
        ".cache/rofi3.druncache"
      ];
    directories = with lib.lists;
      [".config/dconf"]
      ++ optionals config.programs.direnv.enable [
        ".local/share/direnv"
      ]
      ++ optionals config.programs.nushell.enable [
        ".config/nushell"
      ]
      ++ optionals config.programs.neovim.enable [
        ".local/share/nvim"
        ".local/state/nvim"
        ".cache/nvim"
      ];
  };
}
