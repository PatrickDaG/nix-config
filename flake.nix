{
  description = "patricks tolle nix config";

  inputs = {
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # to prevent multiple instances of systems
    systems.url = "github:nix-systems/default";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      # should use system nixpkgs instead of their own
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Bin zu faul des zu kopieren
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    templates.url = "git+https://git.lel.lol/patrick/nix-templates.git";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    impermanence.url = "github:nix-community/impermanence";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixseparatedebuginfod.url = "github:symphorien/nixseparatedebuginfod";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    colmena,
    agenix-rekey,
    nixos-generators,
    pre-commit-hooks,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    stateVersion = "23.05";
  in
    {
      secretsConfig = {
        masterIdentities = [./secrets/NIXOSc.key.pub];
        #masterIdentities = [./secrets/NIXOSa.key.pub];
        extraEncryptionPubkeys = [./secrets/recipients.txt];
      };

      inherit stateVersion;
      inherit
        (import ./nix/hosts.nix inputs)
        colmena
        hosts
        microvmConfigurations
        nixosConfigurations
        ;
      nodes = self.nixosConfigurations // self.microvmConfigurations;
      top = lib.mapAttrs (_: x: x.config.system.build.toplevel) self.nodes;

      inherit
        (lib.foldl' lib.recursiveUpdate {}
          (lib.mapAttrsToList
            (import ./nix/generate-installer-package.nix inputs)
            self.nixosConfigurations))
        packages
        ;
    }
    // flake-utils.lib.eachDefaultSystem (system: rec {
      pkgs = import nixpkgs {
        overlays =
          import ./lib inputs
          ++ import ./pkgs
          ++ [
            inputs.nixpkgs-wayland.overlay
          ];
        inherit system;
        # TODO fix this to only allow specific unfree packages
        config.allowUnfree = true;
      };

      images.live-iso = nixos-generators.nixosGenerate {
        inherit pkgs;
        modules = [
          ./nix/installer-configuration.nix
          ./modules/os-conf/core/ssh.nix
          {system.stateVersion = stateVersion;}
        ];
        format =
          {
            x86_64-linux = "install-iso";
            aarch64-linux = "sd-aarch64-installer";
          }
          .${system};
      };

      apps = agenix-rekey.defineApps self pkgs self.nodes;
      checks.pre-commit-check =
        pre-commit-hooks.lib.${system}.run
        {
          src = lib.cleanSource ./.;
          hooks = {
            alejandra.enable = true;
            statix.enable = true;
            luacheck.enable = true;
            stylua.enable = true;
          };
        };
      devShell = import ./nix/devshell.nix inputs system;
      formatter = pkgs.alejandra;
    });
}
