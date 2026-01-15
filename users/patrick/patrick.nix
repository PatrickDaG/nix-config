{
  pkgs,
  inputs,
  ...
}:
{
  hm.home = {
    packages = with pkgs; [
      (aspellWithDicts (
        dicts: with dicts; [
          de
          en
          en-computers
          en-science
          es
          fr
          la
        ]
      ))
      inputs.flint.packages.${pkgs.stdenv.hostPlatform.system}.flint
      #keep-sorted start
      amazon
      bashInteractive
      bs-manager
      chatterino2
      chromium
      cmatrix
      cowsay
      discord
      disneyplus
      element-desktop
      espeak
      feh
      figlet
      galaxy-buds-client
      gh
      gh-dash
      helvum
      hexyl
      hyperfine
      hyprshot
      jjui
      lazyjj
      #ladybird
      makemkv
      mpv
      netflix
      nextcloud-client
      nix-output-monitor
      nixpkgs-review
      obsidian
      orca-slicer
      osu-lazer-bin
      pandoc # for obsidian
      pdfpc
      pinentry-gnome3 # for yubikey pinentry
      ripgrep-all
      signal-desktop
      streamlink
      streamlink-twitch-gui-bin
      telegram-desktop
      timer
      via
      webcord
      #xautoclick
      xournalpp
      ytdlp-pot-provider
      zathura
      zotero
      zulip
      slack
      #keep-sorted end
    ];
  };
  hm.programs.claude-code.enable = true;
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
      -o "%(epoch>%Y-%m-%dT%H:%M:%SZ)s%(uploader)s_%(title)s.%(ext)s"
    '';
    settings = {
      sponsorblock-remove = "sponsor";
      sponsorblock-mark = "all";
      cookies-from-browser = "firefox";
    };
  };
  environment.systemPackages = [
    (pkgs.sddm-astronaut.override { embeddedTheme = "purple_leaves"; })
  ];
  services.displayManager = {
    defaultSession = "niri";
    sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      extraPackages = [
        pkgs.sddm-astronaut
      ];
    };
  };
  boot.plymouth = {
    enable = true;
    theme = "rings";
    themePackages = with pkgs; [
      # By default we would install all themes
      (adi1090x-plymouth-themes.override {
        selected_themes = [
          "circuit"
          "colorful_sliced"
          "deus_ex"
          "dna"
          "dragon"
          "ibm"
          "lone"
          "rings"
          "rings_2"
          "square"
        ];
      })
    ];
  };
  boot.kernelParams = [
    "quiet"
  ];
  boot.loader.timeout = 2;
}
