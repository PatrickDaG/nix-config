{
  description = "patricks tolle nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # to prevent multiple instances of systems
    systems.url = "github:nix-systems/default";

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

    hyprland = {
      url = "github:hyprwm/Hyprland";
      #url = "/home/patrick/Downloads/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    colmena,
    agenix-rekey,
    devshell,
    ...
  } @ inputs:
    {
      secretsConfig = {
        masterIdentities = [./secrets/NIXOSc.key.pub];
        extraEncryptionPubkeys = [./secrets/recipients.txt];
      };

      stateVersion = "23.05";

      extraLib = import ./nix/lib.nix inputs;

      hosts = {
        patricknix = {
          type = "nixos";
          system = "x86_64-linux";
        };
      };

      colmena = import ./nix/colmena.nix inputs;
      # all bare metal nodes
      colmenaNodes = ((colmena.lib.makeHive self.colmena).introspect (x: x)).nodes;
      # todo add microvmNodes

      nodes = self.colmenaNodes;
    }
    // flake-utils.lib.eachDefaultSystem (system: rec {
      pkgs = import nixpkgs {
        inherit system;
        # TODO fix this to only allow specific unfree packages
        config.allowUnfree = true;
      };
      apps = agenix-rekey.defineApps self pkgs self.nodes;
      checks = import ./nix/checks.nix inputs system;
      devShell = import ./nix/devshell.nix inputs system;
      formatter = pkgs.alejandra;
    });
}
