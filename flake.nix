{
  description = "patricks tolle nix config";

  inputs = {
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-extra-modules = {
      url = "github:oddlama/nixos-extra-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

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
      inputs.flake-utils.follows = "flake-utils";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-nftables-firewall = {
      url = "github:thelegy/nixos-nftables-firewall";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    templates.url = "git+https://forge.lel.lol/patrick/nix-templates.git";

    nix-topology.url = "github:oddlama/nix-topology";

    impermanence.url = "github:nix-community/impermanence";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    spicetify-nix.url = "github:the-argus/spicetify-nix";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    agenix-rekey,
    nixos-generators,
    pre-commit-hooks,
    devshell,
    nixvim,
    nixos-extra-modules,
    nix-topology,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    stateVersion = "23.05";
  in
    {
      secretsConfig = {
        # This should be a link to one of the age public keys is './keys'
        masterIdentities = [./keys/PatC.key];
        extraEncryptionPubkeys = [./secrets/recipients.txt];
      };
      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        inherit (self) nodes pkgs;
      };

      inherit stateVersion;
      inherit
        (import ./nix/hosts.nix inputs)
        hosts
        nixosConfigurations
        minimalConfigurations
        guestConfigurations
        ;
      nodes = self.nixosConfigurations // self.guestConfigurations;

      inherit
        (lib.foldl' lib.recursiveUpdate {}
          (lib.mapAttrsToList
            (import ./nix/generate-installer-package.nix inputs)
            self.minimalConfigurations))
        packages
        ;
    }
    // flake-utils.lib.eachDefaultSystem (system: rec {
      apps.setupHetznerStorageBoxes = import (nixos-extra-modules + "/apps/setup-hetzner-storage-boxes.nix") {
        inherit pkgs;
        nixosConfigurations = self.nodes;
        decryptIdentity = builtins.head self.secretsConfig.masterIdentities;
      };
      pkgs = import nixpkgs {
        overlays =
          import ./lib inputs
          ++ import ./pkgs
          ++ [
            # nixpkgs-wayland.overlay
            nixos-extra-modules.overlays.default
            nix-topology.overlays.default
            devshell.overlays.default
            agenix-rekey.overlays.default
            nixvim.overlays.default
          ];
        inherit system;
        config.allowUnfree = true;
      };

      topology = import nix-topology {
        inherit pkgs;
        modules = [
          {inherit (self) nixosConfigurations;}
          ./nix/topology.nix
        ];
      };

      images.live-iso = nixos-generators.nixosGenerate {
        inherit pkgs;
        modules = [
          ./nix/installer-configuration.nix
          ./config/basic/ssh.nix
        ];
        format =
          {
            x86_64-linux = "install-iso";
            aarch64-linux = "sd-aarch64-installer";
          }
          .${system};
      };

      checks.pre-commit-check =
        pre-commit-hooks.lib.${system}.run
        {
          src = lib.cleanSource ./.;
          hooks = {
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            hunspell.enable = true;
          };
        };
      devShell = import ./nix/devshell.nix inputs system;
      formatter = pkgs.alejandra;
    });
}
