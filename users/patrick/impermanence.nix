{
  home.persistence."/state" = {
    directories = [
      "repos"
      "Downloads"

      # For nextcloud client install
      "Nextcloud"
      ".config/Nextcloud"

      # for electron signal app state
      ".config/Signal"
      ".config/discord"

      # Folders for steam
      ".local/share/Steam"
      ".steam"
      # Ken follets pillars of earth
      ".local/share//Daedalic Entertainment GmbH/"
      # Nvidia shader cache
      ".cache/nvidia"
      # Vulkan shader cache
      ".local/share/vulkan"

      # bottles state games
      ".local/share/bottles"
    ];
  };
}
