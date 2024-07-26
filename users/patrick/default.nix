{
  pkgs,
  config,
  lib,
  minimal,
  ...
}:
lib.optionalAttrs (!minimal) {
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
  age.secrets = {
    smb-creds = {
      owner = "patrick";
      rekeyFile = ../../secrets/smb.cred.age;
    };
  };

  programs.dconf.enable = true;
  age.secrets."my-gpg-yubikey-keygrip.tar" = {
    rekeyFile = ./secrets/gpg-keygrip.tar.age;
    group = "patrick";
    mode = "640";
  };

  home-manager.users.patrick = {
    imports =
      [
        ./patrick.nix
        ./ssh.nix
        ./firefox.nix
        ./gpg
        ./impermanence.nix

        ../common
        ../common/impermanence.nix

        ../common/programs/bottles.nix
        ../common/programs/direnv.nix
        ../common/programs/firefox.nix
        ../common/programs/gdb.nix
        ../common/programs/git.nix
        ../common/programs/kitty.nix
        ../common/programs/minecraft.nix
        ../common/programs/nvim
        ../common/programs/poe.nix
        ../common/programs/spicetify.nix
        ../common/programs/thunderbird.nix
        ../common/shells/pager.nix
      ]
      ++ {
        "desktopnix" = [
          ../common/graphical/Xorg
          ./streamdeck.nix
          ../common/programs/obs.nix
          ../common/graphical/wayland
          ./smb.nix
        ];
        "patricknix" = [ ../common/graphical/wayland ];
      }
      .${config.node.name} or [ ];
  };
}
