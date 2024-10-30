{
  pkgs,
  ...
}:
{
  hm.home = {
    packages = with pkgs; [
      chatterino2
      chromium
      cmatrix
      cowsay
      discord
      feh
      figlet
      galaxy-buds-client
      gh
      hexyl
      hyperfine
      mpv
      netflix
      nextcloud-client
      nixpkgs-review
      orca-slicer
      osu-lazer-bin
      pinentry-gnome3 # for yubikey pinentry
      signal-desktop
      streamlink
      streamlink-twitch-gui-bin
      teamspeak_client
      telegram-desktop
      timer
      via
      webcord
      xournalpp
      yt-dlp
      zathura
      zotero
    ];
  };
  hm.programs.bat.enable = true;
  # needed for gnome pinentry
  services.dbus.packages = [ pkgs.gcr ];
  hm = {
    xdg.configFile."streamlink/config".text = ''
      player=mpv
    '';
    xdg.configFile."mpv/mpv.conf".text = ''
      vo=gpu-next
      hwdec=auto-safe
      volume=50
    '';
    xdg.configFile."mpv/input.conf".text = ''
      UP add volume 2
      DOWN add volume -2
    '';
  };
}
