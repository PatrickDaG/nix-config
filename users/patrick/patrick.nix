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
      libreoffice
    ];
  };
}
