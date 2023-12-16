{
  stateVersion,
  inputs,
  pkgs,
  ...
}: {
  imports = [./impermanence/users.nix];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = {
      spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
    };
    sharedModules = [
      {
        home.stateVersion = stateVersion;
      }
      inputs.nix-index-database.hmModules.nix-index
      inputs.wired-notify.homeManagerModules.default
      inputs.spicetify-nix.homeManagerModule
      inputs.nixvim.homeManagerModules.nixvim
    ];
  };
  # HM zsh needs this or else the startup order is fucked
  # and env variables will be loaded incorrectly
  programs.zsh.enable = true;
}
