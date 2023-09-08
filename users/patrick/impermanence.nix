{
  environment = {
    persistence."/state".users.patrick = {
      directories = [
        "repos"
        "Downloads"

        # For nextcloud client install
        "Nextcloud"
        ".config/Nextcloud"

        # for electron signal app state
        ".config/Signal"
        ".config/discord"
        # persist sound config
        ".local/state/wireplumber"
        # Folders for steam
        ".local/share/Steam"
        ".steam"
        # Ken follets pillars of earth
        ".local/share//Daedalic Entertainment GmbH/"
        # Nvidia shader cache
        ".cache/nvidia"
        # lutris cache
        ".local/share/lutris"
        # lutric games
        "Games"
      ];
    };
  };
}
