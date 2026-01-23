{ config, lib, ... }:
{
  hm.home.persistence = {
    "/state" = {
      files = [
        ".ssh/known_hosts"
        ".claude.json"
        ".claude.json.backup"
      ];
      directories = [
        "repos"
        "Downloads"

        "Zotero"
        ".zotero"

        ".config/ts3client"

        ".config/xournalpp"
        ".cache/xournalpp"

        ".local/state/wireplumber"

        ".config/OrcaSlicer"

        ".cache/typst"

        ".config/streamcontroller"
        ".local/share/streamcontroller"
        #TODO: remove once merged
        ".var/app/com.core447.StreamController/"

        # for netflix
        ".config/google-chrome"
        ".cache/google-chrome"
        # for netflix
        ".config/disneyplus"
        ".config/amazon-prime"

        ".config/gh"

        ".local/share/osu"

        ".local/share/monado"

        ".local/share/keyrings"

        # For nextcloud client install
        "Nextcloud"
        ".config/Nextcloud"
        ".config/dconf"

        # for electron signal app state
        ".config/Signal"
        ".config/streamlink-twitch-gui"
        ".config/discord"
        ".config/WebCord"
        ".local/share/TelegramDesktop"

        ".cache/mpv"
        ".claude"

        ".config/Element"
        ".config/bs-manager"
        ".local/share/bs-manager"

        ".config/spotify"
        ".cache/spotify"
        ".local/share/cargo"
        ".local/share/wallpapers"
        ".factorio"

        ".config/obsidian"
        ".config/Zulip"
        ".config/Slack"
        ".local/share/Terraria"
      ];
    };
    "/panzer/state".directories = lib.lists.optionals (config.disko.devices.zpool ? "panzer") [
      "videos"
    ];
  };
}
