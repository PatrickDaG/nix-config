{ nixosConfig, lib, ... }:
{
  home.persistence = {
    "/state" = {
      directories = [
        "repos"
        "Downloads"

        "Zotero"

        ".config/ts3client"

        ".config/xournalpp"
        ".cache/xournalpp"

        ".config/OrcaSlicer"

        ".config/streamcontroller"
        ".local/share/streamcontroller"
        #TODO: remove once merged
        ".var/app/com.core447.StreamController/"

        # for netflix
        ".config/google-chrome"
        ".cache/google-chrome"

        ".config/Mullvad VPN"

        ".local/share/osu"

        ".config/obs-studio"

        # For nextcloud client install
        "Nextcloud"
        ".config/Nextcloud"

        # for electron signal app state
        ".config/Signal"
        ".config/streamlink-twitch-gui"
        ".config/discord"
        ".config/WebCord"
        ".local/share/TelegramDesktop"

        ".cache/mpv"

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
        ".local/share/cargo"
        #".local/share/wallpapers"
      ];
    };
    "/panzer/state".directories = lib.lists.optionals (nixosConfig.disko.devices.zpool ? "panzer") [
      ".local/share/SteamPanzer"
      "videos"
    ];
  };
}
