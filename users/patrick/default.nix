{
  pkgs,
  config,
  ...
}: {
  # enable nixos wide wayland config
  imports = [
    ../../modules/graphical/wayland.nix
    ../../modules/graphical/xserver.nix
    ../../modules/graphical/steam.nix
    ./impermanence.nix
  ];

  users.users.patrick = {
    shell = pkgs.zsh;
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    extraGroups = ["wheel" "audio" "video" "input"];
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
      ../common/interactive.nix
      ../common/graphical
    ];
  };
}
