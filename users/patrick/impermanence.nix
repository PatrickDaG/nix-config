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

        "./Nextcloud"
        ".config/Nextcloud"
      ];
    };
  };
}
