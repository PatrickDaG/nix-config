{
  impermanence,
  hyprland,
  stateVersion,
  config,
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
      impermanence.home-manager.impermanence
      hyprland.homeManagerModules.default
    ];
    extraSpecialArgs = {
      nixosConfig = config;
    };
  };
  # HM zsh needs this or else the startup order is fucked
  # and env variables will be loaded incorrectly
  programs.zsh.enable = true;
}
