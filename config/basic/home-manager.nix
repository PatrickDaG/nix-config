{
  stateVersion,
  inputs,
  pkgs,
  nodes,
  ...
}:
{
  imports = [
    ../../modules-hm/impermanence.nix
    ../../modules-hm/images.nix
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = {
      inherit nodes;
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    };
    sharedModules = [
      { home.stateVersion = stateVersion; }
      inputs.nix-index-database.hmModules.nix-index
      inputs.nixos-extra-modules.homeManagerModules.default
      inputs.nixvim.homeManagerModules.nixvim
      inputs.spicetify-nix.homeManagerModules.default
    ];
  };
  # HM zsh needs this or else the startup order is fucked
  # and env variables will be loaded incorrectly
  programs.zsh = {
    enable = true;
    # prevent zsh from calling compinit twice with different fpaths
    # This overrides compdump each time, in turn making startup very slow
    enableCompletion = false;
  };

  # But still link all completions from all packages so they
  # can be found by zsh
  environment.pathsToLink = [ "/share/zsh" ];
}
