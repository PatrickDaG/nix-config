{
  nixosConfig,
  lib,
  ...
}: {
  home.persistence = {
    "/state" = {
      directories = [
        "repos"
        "Downloads"

        "invokeai"
        ".textgen"
        ".ollama"
        ".config/Mumble"

        # For nextcloud client install
        "Nextcloud"
        ".config/Nextcloud"

        # for electron signal app state
        ".config/Signal"
        ".config/discord"
        ".local/share/TelegramDesktop"

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

        ".config/spotify"
        ".cache/spotify"
      ];
    };
    "/panzer/state".directories =
      lib.lists.optionals (nixosConfig.disko.devices.zpool ? "panzer")
      [
        ".local/share/SteamPanzer"
      ];
  };
}
