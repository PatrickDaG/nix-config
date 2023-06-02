{pkgs, ...}: {
  imports = [
    ./shells/alias.nix
    ./shells/zsh

    ./programs/gpg

    ./impermanence.nix
  ];

  home.packages = with pkgs; [
    bat
  ];
  nixpkgs.config = {
    allowUnfree = true;
  };
}
