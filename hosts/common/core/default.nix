{
  imports = [
    ./inputrc.nix
    ./issue.nix
    ./net.nix
    ./nix.nix
    ./ssh.nix
    ./system.nix
    ./xdg.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
  };
  # HM zsh needs this or else the startup order is fucked
  # and env variables will be loaded incorrectly
  programs.zsh.enable = true;
}
