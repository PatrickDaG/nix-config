{
  inputs,
  nodes,
  minimal,
  ...
}:
{
  imports = [
    ../../modules-hm/impermanence.nix
    ../../modules-hm/hm-all.nix
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = {
      inherit nodes minimal;
    };
    sharedModules = [
      {
        home.stateVersion = "24.05";
        systemd.user.startServices = "sd-switch";
      }
      inputs.nix-index-database.hmModules.nix-index
      inputs.nixos-extra-modules.modules.home-manager.default
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
