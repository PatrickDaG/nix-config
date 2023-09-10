{pkgs, ...}: {
  imports = [
    ./shells/alias.nix
    ./shells/zsh
    ./shells/nushell.nix

    ./programs/gpg
  ];

  home.packages = with pkgs; [
    bat
  ];
  nixpkgs.config = {
    allowUnfree = true;
  };
}
