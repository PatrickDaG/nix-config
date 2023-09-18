{pkgs, ...}: {
  imports = [
    ./shells/alias.nix
    ./shells/zsh
    ./shells/pager.nix

    ./programs/gpg
  ];

  home.packages = with pkgs; [
    bat
  ];
  nixpkgs.config = {
    allowUnfree = true;
  };
}
