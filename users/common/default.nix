{pkgs, ...}: {
  imports = [
    ./shells/alias.nix
    ./shells/zsh

    ./programs/gpg
  ];

  home.packages = with pkgs; [
    bat
  ];
  nixpkgs.config = {
    allowUnfree = true;
  };
}
