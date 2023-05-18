{hyprland, ...}: {
  # TODO: only import this if the current host is a nixos host
  imports = [
    ../../hosts/common/graphical/hyprland.nix
  ];
  home-manager.users.patrick.imports = [
    hyprland.homeManagerModules.default
    ./patrick.nix
    ../common
  ];

  home-manager.users.root = {
    imports = [../common];
  };
}
