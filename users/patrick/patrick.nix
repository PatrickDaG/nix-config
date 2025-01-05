{
  pkgs,
  ...
}:
{
  hm.home = {
    packages = with pkgs; [
      bashInteractive
      chatterino2
      chromium
      cmatrix
      cowsay
      discord
      disneyplus
      element-desktop
      feh
      figlet
      galaxy-buds-client
      gh
      gh-dash
      hexyl
      hyperfine
      mpv
      netflix
      nextcloud-client
      nix-output-monitor
      nixpkgs-review
      #orca-slicer
      osu-lazer-bin
      pinentry-gnome3 # for yubikey pinentry
      signal-desktop
      streamlink
      streamlink-twitch-gui-bin
      teamspeak_client
      telegram-desktop
      timer
      via
      wcurl
      webcord
      xournalpp
      yt-dlp
      zathura
      zotero
      qmk
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
      volume=80
    '';
    xdg.configFile."mpv/input.conf".text = ''
      UP add volume 2
      DOWN add volume -2
    '';
  };
  services.udev.packages = [ pkgs.qmk-udev-rules ];
}
