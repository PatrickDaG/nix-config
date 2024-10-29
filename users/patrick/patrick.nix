{
  pkgs,
  lib,
  nixosConfig,
  ...
}:
{
  home = {
    packages = with pkgs; [
      nextcloud-client
      discord
      webcord
      netflix
      xournalpp
      galaxy-buds-client
      thunderbird
      signal-desktop
      telegram-desktop
      chromium
      osu-lazer-bin
      teamspeak_client
      zotero
      timer
      orca-slicer
      hexyl
      gh
      nixpkgs-review

      via

      streamlink
      streamlink-twitch-gui-bin
      chatterino2

      yt-dlp

      hyperfine

      figlet
      cowsay
      cmatrix
    ];
  };
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
  # Make sure the keygrips exist, otherwise we'd need to run `gpg --card-status`
  # before being able to use the yubikey.
  home.activation.installKeygrips = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.gnupg/private-keys-v1.d"
    run ${lib.getExe pkgs.gnutar} xvf ${
      lib.escapeShellArg nixosConfig.age.secrets."my-gpg-yubikey-keygrip.tar".path
    } -C "$HOME/.gnupg/private-keys-v1.d/"
  '';
  # Autostart hyprland if on tty1 (once, don't restart after logout)
  programs.zsh.initExtra = lib.mkOrder 9999 ''
    if uwsm check may-start ; then
    	exec systemd-cat -t uwsm_start uwsm start -S -F Hyprland
    fi
  '';
}
