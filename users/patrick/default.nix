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
    uid = 1000;
    createHome = true;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "input"
      # TPM settings
      "tss"
      "wireshark"
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
  users.groups.patrick.gid = config.users.users.patrick.uid;

  environment.systemPackages = with pkgs; [
    # xournalpp needs this or else it will crash
    gnome3.adwaita-icon-theme
  ];
  age.secrets = {
    smb-creds = {
      owner = "patrick";
      rekeyFile = ../../secrets/smb.cred.age;
    };
  };
  programs.dconf.enable = true;

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

        ../common/programs/direnv.nix
        ../common/programs/htop.nix
        ../common/programs/git.nix
        ../common/programs/bottles.nix
        ../common/programs/gdb.nix
        ../common/programs/firefox.nix
        ../common/programs/kitty.nix
        ../common/programs/thunderbird.nix
        ../common/programs/spicetify.nix
        ../common/programs/minecraft.nix
      ]
      ++ {
        "desktopnix" = [
          ../common/graphical/Xorg
          ./streamdeck.nix
          ../common/programs/obs.nix
          ./smb.nix
        ];
        "patricknix" = [
          ../common/graphical/wayland
        ];
      }
      .${config.node.name}
      or [];
  };
}
