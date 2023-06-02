{
  hyprland,
  impermanence,
  pkgs,
  config,
  stateVersion,
  ...
}: {
  # TODO: only import this if the current host is a nixos host
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
    home.stateVersion = stateVersion;
    imports = [
      hyprland.homeManagerModules.default
      impermanence.home-manager.impermanence
      ./patrick.nix
      ../common
    ];
  };
}
