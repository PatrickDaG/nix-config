{
  config,
  extraLib,
  ...
}: {
  home = {
    persistence."/state/${config.home.homeDirectory}" = {
      allowOther = true;
      directories = extraLib.impermanence.makeSymlinks [
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
