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

    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    templates = {
      url = "./templates";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix,
    flake-utils,
    templates,
    hyprland,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in
    {
      nixosConfigurations.patricknix = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          {home-manager.users.patrick.imports = [hyprland.homeManagerModules.default];}
          agenix.nixosModules.default
          {
            nix.registry = {
              nixpkgs.flake = nixpkgs;
              p.flake = nixpkgs;
              pkgs.flake = nixpkgs;
              templates.flake = templates;
            };
          }
          hyprland.nixosModules.default
        ];
      };
    }
    // flake-utils.lib.eachSystem [system] (localSystem: rec {
      pkgs = import nixpkgs {
        inherit localSystem;
      };
      apps = import ./apps/rekey.nix inputs localSystem;

      devShells.default = pkgs.mkShell {
        name = "nixos config";

        packages = with pkgs; [
          alejandra
          statix
          update-nix-fetchgit
        ];

        shellHook = ''
          ${self.checks.${system}.pre-commit-check.shellHook}
        '';
      };

      checks = import ./modules/checks.nix inputs localSystem;
    });
}
