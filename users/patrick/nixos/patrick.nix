{
  pkgs,
  config,
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
              es
              fr
              la
            ]
          ))
          #keep-sorted start
          bashInteractive
          btop-cuda
          #crosspipe
          dig
          discord
          dust
          element-desktop
          feh
          gh
          gh-dash
          glow
          hyperfine
          magic-wormhole
          mpv
          #nextcloud-client # 2GB?
          nix-output-monitor
          nixpkgs-review
          obsidian
          pandoc # for obsidian
          pass
          pinentry-gnome3 # for yubikey pinentry
          ripgrep-all
          signal-desktop
          streamlink
          #streamlink-twitch-gui-bin # Why this 500MB????
          timewarrior
          zathura
          zotero
          #keep-sorted end
        ];
        thinknix = [
          slack
          zulip
          galaxy-buds-client
          #pdfpc
        ];
      };
  };

  #services.davfs2.enable = true;

  hm.programs.bat.enable = true;
  # needed for gnome pinentry
  services.dbus.packages = [ pkgs.gcr_3 ];
  hm = {
    # The profile-installed Zoom package supplies this desktop file.
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/zoommtg" = [ "Zoom.desktop" ];
        "x-scheme-handler/zoomus" = [ "Zoom.desktop" ];
      };
    };
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
  services.displayManager = {
    noctalia-greeter = {
      enable = true;
      cursorTheme = {
        inherit (config.stylix.cursor) package name;
      };
      settings = {
        session.default = "niri";
        cursor.size = config.stylix.cursor.size;
        keyboard = {
          # Match the Niri session, including the alternate Bone layout.
          layout = "de,de";
          variant = "nodeadkeys,bone";
          options = "grp:win_space_toggle";
        };
      };
    };
  };
  boot.plymouth = {
    enable = true;
    theme = "rings";
    themePackages = with pkgs; [
      # By default we would install all themes
      (adi1090x-plymouth-themes.override {
        selected_themes = [
          "rings"
          # "circuit"
          # "colorful_sliced"
          # "deus_ex"
          # "dna"
          # "dragon"
          # "ibm"
          # "lone"
          # "rings_2"
          # "square"
        ];
      })
    ];
  };
  boot.kernelParams = [
    "quiet"
  ];
  boot.loader.timeout = 2;

  hm.programs.calibre = {
    enable = true;
    plugins = with pkgs; [
      deacsm
      dedrm
      koreader-sync
    ];
  };
}
