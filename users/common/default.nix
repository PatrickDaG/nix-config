{
  imports = [
    ./shells/alias.nix
    ./shells/zsh

    ./programs/gpg

    ./impermanence.nix
  ];
  nixpkgs.config = {
    allowUnfree = true;
  };
}
