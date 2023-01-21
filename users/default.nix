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
	imports = [ ./common ];
    programs.neovim.enable = true;
    programs.git.enable = true;
    xdg.configFile.nvim = {
      recursive = true;
      source = ../data/nvim;
    };
    home.stateVersion = "23.05";
  };
}
