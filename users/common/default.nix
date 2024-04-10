{
  imports = [
    ./shells/alias.nix
    ./shells/zsh

    ./programs/gpg.nix
    ./programs/htop.nix
  ];

  programs.bat.enable = true;
  nixpkgs.config = {
    allowUnfree = true;
  };
}
