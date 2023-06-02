{pkgs, ...}: {
  imports = [
    ./programs/direnv.nix
    ./programs/htop.nix
    ./programs/nvim
    ./programs/git.nix
  ];

  home.packages = with pkgs; [
    bat
  ];
}
