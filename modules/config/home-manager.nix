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
      inputs.nixos-extra-modules.homeManagerModules.default
      inputs.nixvim.homeManagerModules.nixvim
      inputs.spicetify-nix.homeManagerModule
      inputs.wired-notify.homeManagerModules.default
    ];
  };
  # HM zsh needs this or else the startup order is fucked
  # and env variables will be loaded incorrectly
  programs.zsh.enable = true;
}
