{
  hm.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  hm.home.persistence."/state".directories = [
    ".local/share/direnv"
  ];
}
