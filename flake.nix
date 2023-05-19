{
  description = "patricks tolle nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    flake-utils.url = "github:numtide/flake-utils";

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

    # someday
    #impermanence.url = "github:nix-community/impermanence";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    colmena,
    agenix-rekey,
    ...
  } @ inputs:
    {
      secrets = {
        masterIdentities = [./secrets/NIXOSc.key.pub];
        extraEncryptionPubkeys = [./secrets/recipients.txt];
        content = import ./nix/secrets.nix inputs;
      };

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
      devShells.default = import ./nix/dev-shell.nix inputs system;
      formatter = pkgs.alejandra;
    });
}
