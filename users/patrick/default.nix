{
  pkgs,
  config,
  ...
}: {
  # enable nixos wide hyprland config
  imports = [
    ../../hosts/common/graphical/hyprland.nix
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

  home-manager.users.patrick = {
    imports = [
      ./patrick.nix
      ./ssh.nix
      ./impermanence.nix
      ../common
      ../common/interactive.nix
      ../common/graphical.nix
    ];
  };
}
