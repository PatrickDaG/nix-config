{
  stateVersion,
  inputs,
  pkgs,
  nodes,
  ...
}: {
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
      spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
    };
    sharedModules = [
      {
        home.stateVersion = stateVersion;
      }
      inputs.nix-index-database.hmModules.nix-index
      inputs.nixos-extra-modules.homeManagerModules.default
      inputs.nixvim.homeManagerModules.nixvim
      inputs.spicetify-nix.homeManagerModule
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
}
