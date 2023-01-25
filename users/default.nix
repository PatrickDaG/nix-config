{
  config,
  home-manager,
  ...
}:
{
  home-manager.users.patrick.imports = [./patrick.nix];
  home-manager.users.root = {
    imports = [./common];
    home.stateVersion = "23.05";
  };
}
