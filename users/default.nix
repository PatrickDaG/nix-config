{
  config,
  pkgs,
  ...
}: let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
  imports = [
    (import "${home-manager}/nixos")
  ];
  home-manager.users.patrick.imports = [./patrick.nix];
  home-manager.users.root = {
    imports = [./common];
    home.stateVersion = "23.05";
  };
}
