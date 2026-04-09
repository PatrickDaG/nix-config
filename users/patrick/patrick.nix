{
  pkgs,
  config,
  inputs,
  ...
}:
{
  hm.home = {
    packages =
      with pkgs;
      config.lib.misc.mkPerHost {
        all = [
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
          btop-cuda
          chromium
          #crosspipe
          dig
          discord
          disneyplus
          dust
          element-desktop
          feh
          gh
          gh-dash
          hyperfine
          magic-wormhole
          mpv
          netflix
          nextcloud-client
          nix-output-monitor
          nixpkgs-review
          obsidian
          pandoc # for obsidian
          pinentry-gnome3 # for yubikey pinentry
          ripgrep-all
          signal-desktop
          streamlink
          streamlink-twitch-gui-bin
          timewarrior
          zathura
          zotero
          zoom-us
          #keep-sorted end
        ];
        thinknix = [
          slack
          zulip
          galaxy-buds-client
          #pdfpc
        ];
        desktopnix = [
          bs-manager
        ];
        patricknix = [
          xournalpp
        ];
      };
  };
  hm.programs.claude-code = {
    enable = true;
    package = pkgs.llm-agents.claude-code;
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
