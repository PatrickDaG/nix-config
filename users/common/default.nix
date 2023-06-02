{
  imports = [
    ./shells/zsh
    ./programs/htop.nix
    ./nvim
    ./shells/alias.nix
    ./git.nix
    ./gpg
    ./util.nix
    ./impermanence.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };
}
