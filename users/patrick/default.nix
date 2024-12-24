{
  pkgs,
  globals,
  lib,
  minimal,
  ...
}:
lib.optionalAttrs (!minimal) {
  primaryUser = "patrick";
  users.users.patrick = {
    shell = pkgs.zsh;
    isNormalUser = true;
    createHome = true;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "input"
      # TPM settings
      "tss"
    ];
    group = "patrick";
    inherit (globals.users.patrick) hashedPassword;
    autoSubUidGidRange = false;
    subUidRanges = [
      {
        count = 65534;
        startUid = 100001;
      }
    ];
    subGidRanges = [
      {
        count = 65534;
        startGid = 100001;
      }
    ];
  };
  users.groups.patrick = { };

  environment.systemPackages = with pkgs; [
    # xournalpp needs this or else it will crash
    adwaita-icon-theme
  ];

  programs.dconf.enable = true;

  imports = [

    ./alias.nix
    ./dev.nix
    ./impermanence.nix
    ./patrick.nix
    ./smb.nix
    ./ssh.nix
    ./theme.nix

    ./wayland
    ./Xorg

    ./programs/bottles.nix
    ./programs/direnv.nix
    ./programs/firefox.nix
    ./programs/gdb.nix
    ./programs/git.nix
    ./programs/gpg
    ./programs/gpu-screen-recorder.nix
    ./programs/htop.nix
    ./programs/kitty.nix
    ./programs/minecraft.nix
    ./programs/minion.nix
    ./programs/nvim
    ./programs/obs.nix
    ./programs/pager.nix
    ./programs/poe.nix
    ./programs/spicetify.nix
    ./programs/steam.nix
    ./programs/thunderbird.nix
    ./programs/zsh

  ];
}
