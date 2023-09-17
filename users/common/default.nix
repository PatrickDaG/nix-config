{pkgs, ...}: {
  imports = [
    ./shells/alias.nix
    ./shells/zsh
    ./shells/nu

    ./programs/gpg
  ];

  home.packages = with pkgs; [
    bat
  ];
  nixpkgs.config = {
    allowUnfree = true;
  };
}
