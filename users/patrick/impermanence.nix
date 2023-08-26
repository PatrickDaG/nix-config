{
  config,
  pkgs,
  ...
}: {
  home = {
    persistence."/state/${config.home.homeDirectory}" = {
      allowOther = true;
      directories = pkgs.lib.impermanence.makeSymlinks [
        "repos"
        "Downloads"

        # For nextcloud client install
        "./Nextcloud"
        ".config/Nextcloud"

        # for electron signal app state
        ".config/signal"
      ];
    };
  };
}
