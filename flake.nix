{
  description = "patricks tolle nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixp-meta.url = "git+https://forge.lel.lol/patrick/nixp-meta.git";

    nixpkgs-octoprint.url = "github:patrickdag/nixpkgs/octoprint-update";
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-extra-modules = {
      url = "github:oddlama/nixos-extra-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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

    flake-parts.url = "github:hercules-ci/flake-parts";

    # Bin zu faul des zu kopieren
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
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

    #stylix.url = "github:danth/stylix";
    # https://github.com/danth/stylix/pull/589
    stylix.url = "github:danth/stylix/ed91a20c84a80a525780dcb5ea3387dddf6cd2de";

    spicetify-nix = {
      url = "github:Gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixos-generators,
      nixos-extra-modules,
      nix-topology,
      ...
    }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./nix/agenix-rekey.nix
        ./nix/devshell.nix
        ./nix/hosts.nix
        ./nix/pkgs.nix
        ./nix/patch.nix
        nix-topology.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, system, ... }:
        {
          topology.modules = [ ./nix/topology.nix ];
          apps.setupHetznerStorageBoxes =
            import (nixos-extra-modules + "/apps/setup-hetzner-storage-boxes.nix")
              {
                inherit pkgs;
                nixosConfigurations = inputs.self.nodes;
                decryptIdentity = builtins.head self.secretsConfig.masterIdentities;
              };
          packages.live-iso = nixos-generators.nixosGenerate {
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

        };
    };
}
