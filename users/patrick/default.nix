{
  pkgs,
  config,
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
    hashedPassword = config.secrets.secrets.global.users.patrick.passwordHash;
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
  age.secrets."my-gpg-yubikey-keygrip.tar" = {
    rekeyFile = ./secrets/gpg-keygrip.tar.age;
    group = "patrick";
    mode = "640";
  };

  imports = [

    ./firefox.nix
    ./gpg
    ./impermanence.nix
    ./minion.nix
    ./patrick.nix
    ./smb.nix
    ./ssh.nix
    ./theme.nix

    ../common/alias.nix
    ../common/dev.nix
    ../common/wayland

    ../common/programs/bottles.nix
    ../common/programs/direnv.nix
    ../common/programs/firefox.nix
    ../common/programs/gdb.nix
    ../common/programs/git.nix
    ../common/programs/gpg.nix
    ../common/programs/gpu-screen-recorder.nix
    ../common/programs/kitty.nix
    ../common/programs/minecraft.nix
    ../common/programs/nvim
    ../common/programs/obs.nix
    ../common/programs/pager.nix
    ../common/programs/poe.nix
    ../common/programs/spicetify.nix
    ../common/programs/steam.nix
    ../common/programs/thunderbird.nix
    ../common/programs/zsh

  ];
}
