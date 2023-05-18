{
  hyprland,
  pkgs,
  config,
  ...
}: {
  # TODO: only import this if the current host is a nixos host
  imports = [
    ../../hosts/common/graphical/hyprland.nix
  ];
  rekey.secrets.patrick.file = ../../secrets/patrick.passwd.age;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.patrick = {
    shell = pkgs.zsh;
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    extraGroups = ["wheel" "audio" "video" "input"];
    group = "patrick";
    passwordFile = config.rekey.secrets.patrick.path;
  };
  users.groups.patrick.gid = config.users.users.patrick.uid;

  environment.systemPackages = with pkgs; [
    # xournalpp needs this or else it will crash
    gnome3.adwaita-icon-theme
  ];
  home-manager.users.patrick.imports = [
    hyprland.homeManagerModules.default
    ./patrick.nix
    ../common
  ];
}
