{
  impermanence,
  stateVersion,
  ...
}: {
  imports = [
    ./inputrc.nix
    ./issue.nix
    ./net.nix
    ./nix.nix
    ./ssh.nix
    ./system.nix
    ./xdg.nix
    ./impermanence.nix

    ../../../nix/secrets.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    sharedModules = [
      {
        home.stateVersion = stateVersion;
      }
      impermanence.home-manager.impermanence
    ];
  };
  # HM zsh needs this or else the startup order is fucked
  # and env variables will be loaded incorrectly
  programs.zsh.enable = true;
}
