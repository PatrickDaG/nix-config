{
  inputs,
  ...
}:
{
  imports = [
    ../../modules-hm/persistence-disabled.nix

    inputs.nix-index-database.homeModules.nix-index
    inputs.nixvim.homeModules.nixvim
    inputs.omp.homeManagerModules.default

    ./alias.nix
    ./ssh.nix
    ./programs/claude.nix
    ./programs/codex.nix
    ./programs/direnv.nix
    ./programs/gdb.nix
    ./programs/git
    ./programs/htop.nix
    ./programs/nvim
    ./programs/pager.nix
    ./programs/pi.nix
    ./programs/zsh
  ];

  home = {
    username = "patrick";
    homeDirectory = "/home/patrick";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";
}
