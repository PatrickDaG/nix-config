{
  imports = [
    ./shells/alias.nix
    ./shells/zsh
    ./shells/pager.nix

    ./programs/gpg.nix
    ./programs/htop.nix
  ];

  programs.bat.enable = true;
  nixpkgs.config = {
    allowUnfree = true;
  };
}
