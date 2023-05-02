{
  config,
  home-manager,
  hyprland,
  ...
}: {
  home-manager.users.patrick.imports = [
    hyprland.homeManagerModules.default
    ./patrick.nix
    ../common
  ];

  home-manager.users.root = {
    imports = [../common];
  };
}
