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
        ".config/signal"
        ".config/discord"
      ];
    };
  };
}
