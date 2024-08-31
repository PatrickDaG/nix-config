{ minimal, lib, ... }:
{
  imports = [
    ./shells/alias.nix
    ./shells/zsh

    ./programs/gpg.nix
  ] ++ lib.optional (!minimal) ./programs/htop.nix;

  programs.bat.enable = true;
  nixpkgs.config = {
    allowUnfree = true;
  };
}
