{
  inputs,
  nodes,
  minimal,
  lib,
  ...
}:
{
  imports = [
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
      #keep-sorted start
      inputs.nix-index-database.homeModules.nix-index
      inputs.nixos-extra-modules.modules.home-manager.default
      inputs.nixvim.homeModules.nixvim
      inputs.spicetify-nix.homeManagerModules.default
      inputs.vicinae.homeManagerModules.default
      #keep-sorted end
    ]
    #If not minimal the stylix nixos module takes care of this
    ++ lib.optionals minimal [
      inputs.stylix.homeModules.stylix
      {
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
