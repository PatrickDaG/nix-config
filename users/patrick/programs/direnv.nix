{
  hm.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.warn_timout = "1m";
  };
  hm.home.persistence."/state".directories = [
    ".local/share/direnv"
  ];
}
