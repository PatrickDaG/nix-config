{pkgs, ...}: {
  images.enable = true;
  home = {
    packages = with pkgs; [
      nextcloud-client
      discord
      netflix
      xournalpp
      galaxy-buds-client
      thunderbird
      signal-desktop
      telegram-desktop
      chromium
      python3
      jq
      osu-lazer-bin
      mumble
      zotero
    ];
  };
}
