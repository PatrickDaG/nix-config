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
  # TODO unify stateversions
  home.stateVersion = "23.05";

  nixpkgs.config = {
    allowUnfree = true;
  };
}
