{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # should use system nixpkgs instead of their own
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.patricknix = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        agenix.nixosModule
        {
          nix.registry = {
            nixpkgs.flake = nixpkgs;
            p.flake = nixpkgs;
            pkgs.flake = nixpkgs;
          };
        }
      ];
    };
  };
}
