{
  imports = [
    ./shells/alias.nix
    ./shells/zsh
    ./shells/pager.nix

    ./programs/gpg
  ];

  programs.bat.enable = true;
  nixpkgs.config = {
    allowUnfree = true;
  };
}
