{
  stateVersion,
  inputs,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    sharedModules = [
      {
        home.stateVersion = stateVersion;
      }
      inputs.nix-index-database.hmModules.nix-index
      inputs.wired-notify.homeManagerModules.default
    ];
  };
  # HM zsh needs this or else the startup order is fucked
  # and env variables will be loaded incorrectly
  programs.zsh.enable = true;
}
