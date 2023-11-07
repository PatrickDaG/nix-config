{
  imports = [
    ./shells/alias.nix
    ./shells/zsh
    ./shells/pager.nix

    ./programs/gpg.nix
    ./programs/nvim
  ];

  programs.bat.enable = true;
  nixpkgs.config = {
    allowUnfree = true;
  };
}
