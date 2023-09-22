{
  pkgs,
  config,
  ...
}: {
  # enable nixos wide graphical config
  imports = [
    ../../modules/optional/xserver.nix
    ../../modules/optional/steam.nix
    ./impermanence.nix
  ];

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
    ];
    group = "patrick";
    hashedPassword = config.secrets.secrets.global.users.patrick.passwordHash;
  };
  users.groups.patrick.gid = config.users.users.patrick.uid;

  environment.systemPackages = with pkgs; [
    # xournalpp needs this or else it will crash
    gnome3.adwaita-icon-theme
  ];
  age.secrets.smb-creds.rekeyFile = ../../secrets/smb.cred.age;
  programs.dconf.enable = true;

  home-manager.users.patrick = {
    imports = [
      ./patrick.nix
      ./ssh.nix
      ./smb.nix

      ../common
      ../common/impermanence.nix
      ../common/graphical

      ../common/programs/direnv.nix
      ../common/programs/htop.nix
      ../common/programs/nvim
      ../common/programs/git.nix
      ../common/programs/bottles.nix
      ../common/programs/gdb.nix
      ../common/programs/streamdeck.nix
      ../common/programs/firefox.nix
      ../common/programs/kitty.nix
      ../common/programs/thunderbird.nix
    ];
  };
}
