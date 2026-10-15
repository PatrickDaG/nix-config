{
  config,
  globals,
  inputs,
  lib,
  minimal,
  nodes,
  ...
}:
{
  imports = [
    ../../modules-hm/users.nix
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = {
      inherit
        globals
        inputs
        nodes
        minimal
        ;
    };
    sharedModules = [
      {
        home.stateVersion = "24.05";
        systemd.user.startServices = "sd-switch";
      }
      #keep-sorted start
      inputs.nix-index-database.homeModules.nix-index
      inputs.nixos-extra-modules.modules.home-manager.default
      inputs.nixvim.homeModules.nixvim
      inputs.noctalia.homeModules.default
      inputs.omp.homeManagerModules.default
      inputs.spicetify-nix.homeManagerModules.default
      inputs.vicinae.homeManagerModules.default
      #keep-sorted end
    ]
    # Use the direct module when Stylix's NixOS integration is inactive.
    ++ lib.optionals (!config.stylix.enable) [
      inputs.stylix.homeModules.stylix
      {
        # NixOS owns the package set because Home Manager uses global packages.
        stylix.overlays.enable = false;
      }
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
