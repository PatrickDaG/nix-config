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
      amazon
      element-desktop
      feh
      figlet
      galaxy-buds-client
      gh
      gh-dash
      hexyl
      hyperfine
      helvum
      mpv
      netflix
      nextcloud-client
      nix-output-monitor
      nixpkgs-review
      #orca-slicer
      osu-lazer-bin
      pinentry-gnome3 # for yubikey pinentry
      pdfpc
      signal-desktop
      streamlink
      streamlink-twitch-gui-bin
      teamspeak3
      telegram-desktop
      timer
      via
      wcurl
      webcord
      xournalpp
      ytdlp-pot-provider
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
  hm.xdg.configFile.yt-dlp-get-pot =
    let
      source = pkgs.fetchFromGitHub {
        owner = "coletdjnz";
        repo = "yt-dlp-get-pot";
        tag = "v0.2.0";
        hash = "sha256-c5iKnZ7rYckbqvEI20nymOV6/QJAWyu/FX0QM6ps2D4=";
      };
    in
    {
      inherit source;
      target = "yt-dlp/plugins/yt-dlp-get-pot";
    };
  hm.xdg.configFile.bgutil-ytdlp-pot-provider =
    let
      source = pkgs.fetchFromGitHub {
        owner = "Brainicism";
        repo = "bgutil-ytdlp-pot-provider";
        tag = "0.7.2";
        hash = "sha256-IiPle9hZEHFG6bjMbe+psVJH0iBZXOMg3pjgoERH3Eg=";
      };
    in
    {
      source = "${source}/plugin";
      target = "yt-dlp/plugins/bgutil-ytdlp-pot-provider";
    };
  hm.programs.yt-dlp = {
    enable = true;
    extraConfig = ''
      --restrict-filenames
      -P "temp:~/tmp"
      -P "~/videos"
      -o "%(uploader)s_$(title)s.%(ext)s"
    '';
    settings = {
      sponsorblock-remove = "sponsor";
      sponsorblock-mark = "all";
      cookies-from-browser = "firefox";
    };
  };
}
