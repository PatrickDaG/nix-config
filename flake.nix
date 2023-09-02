{
  description = "patricks tolle nix config";

  inputs = {
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
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    colmena,
    agenix-rekey,
    devshell,
    nixos-generators,
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

      hosts = builtins.fromTOML (builtins.readFile ./hosts.toml);

      colmena = import ./nix/colmena.nix inputs;
      # all bare metal nodes
      colmenaNodes = ((colmena.lib.makeHive self.colmena).introspect (x: x)).nodes;
      # todo add microvmNodes

      nodes = self.colmenaNodes;

      inherit
        (lib.foldl' lib.recursiveUpdate {}
          (lib.mapAttrsToList
            (import ./nix/generate-installer-package.nix inputs)
            self.colmenaNodes))
        packages
        ;
    }
    // flake-utils.lib.eachDefaultSystem (system: rec {
      pkgs = import nixpkgs {
        overlays = import ./lib inputs;
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
      checks = import ./nix/checks.nix inputs system;
      devShell = import ./nix/devshell.nix inputs system;
      formatter = pkgs.alejandra;
    });
}
