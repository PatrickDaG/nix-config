{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      package = pkgs.lixPackageSets.latest.nix-direnv;
    };
    config.warn_timout = "1m";
  };
  home.persistence."/state".directories = [
    ".local/share/direnv"
  ];
}
