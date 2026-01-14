{
  description = "patricks tolle nix config";

  inputs = {
    # The one, the only
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # deploy tool
    nixp-meta = {
      url = "git+https://forge.lel.lol/patrick/nixp-meta.git";
      inputs = {
        # keep-sorted start
        devshell.follows = "devshell";
        flake-parts.follows = "flake-parts";
        nci.follows = "nci";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
        treefmt-nix.follows = "treefmt-nix";
        # keep-sorted end
      };
    };

    # Everything turns to dust eventually
    impermanence.url = "github:nix-community/impermanence";

    # hardware configs
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # More module systems
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Disk formatting with nix
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Make boot secure
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        # keep-sorted start
        crane.follows = "crane";
        nixpkgs.follows = "nixpkgs";
        pre-commit.follows = "pre-commit-hooks";
        rust-overlay.follows = "rust-overlay";
        # keep-sorted end
      };
    };

    # generate installable images from my config
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage the home
    home-manager = {
      url = "github:nix-community/home-manager";
      # should use system nixpkgs instead of their own
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # So I can be secret
    agenix = {
      url = "github:ryantm/agenix";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs = {
        # keep-sorted start
        devshell.follows = "devshell";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        # keep-sorted end
      };
    };

    # VR application/modules
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs = {
        # keep-sorted start
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        # keep-sorted end
      };
    };

    # gaming modules
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        # keep-sorted start
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        # keep-sorted end
      };
    };

    # Use nix to configure Niri
    # All my homies hate KDL
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Configure nftables firewall with nix
    nixos-nftables-firewall = {
      url = "github:thelegy/nixos-nftables-firewall";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Make good looking
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        # keep-sorted start
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        # keep-sorted end
      };
    };

    # devshell for deving
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        # keep-sorted start
        nixpkgs.follows = "nixpkgs";
        # keep-sorted end
      };
    };
    # TODO: kinda useless currently because jujutsu
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Oddlama and my personal shared modules
    nixos-extra-modules = {
      url = "github:oddlama/nixos-extra-modules/main";
      inputs = {
        # keep-sorted start
        devshell.follows = "devshell";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
        # keep-sorted end
      };
    };

    # My personal nix flake templates
    templates.url = "git+https://forge.lel.lol/patrick/nix-templates.git";

    # Prebuilt database for comma, etc
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # misc applications
    mdns = {
      url = "git+https://forge.lel.lol/patrick/mdns-repeater.git";
      inputs = {
        # keep-sorted start
        devshell.follows = "devshell";
        pre-commit-hooks.follows = "pre-commit-hooks";
        treefmt-nix.follows = "treefmt-nix";
        # keep-sorted end
      };
    };
    idmail = {
      url = "github:oddlama/idmail/";
      inputs = {
        # keep-sorted start
        devshell.follows = "devshell";
        flake-parts.follows = "flake-parts";
        nci.follows = "nci";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
        treefmt-nix.follows = "treefmt-nix";
        # keep-sorted end
      };
    };
    elewrap = {
      url = "github:oddlama/elewrap";
      inputs = {
        # keep-sorted start
        devshell.follows = "devshell";
        nci.follows = "nci";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
        # keep-sorted end
      };
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs = {
        # keep-sorted start
        devshell.follows = "devshell";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
        # keep-sorted end
      };
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        # keep-sorted start
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        # keep-sorted end
      };
    };
    spicetify-nix = {
      url = "github:Gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Don't override nixpks because of caching
    vicinae.url = "github:vicinaehq/vicinae";
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs = {
        # keep-sorted start
        nixpkgs.follows = "nixpkgs";
        vicinae.follows = "vicinae";
        # keep-sorted end
      };
    };
    flint = {
      url = "github:NotAShelf/flint";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # dependencies for deduplication
    nci = {
      url = "github:yusdacra/nix-cargo-integration";
      inputs = {
        # keep-sorted start
        crane.follows = "crane";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
        treefmt.follows = "treefmt-nix";
        # keep-sorted end
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        # keep-sorted start
        nixpkgs.follows = "nixpkgs";
        # keep-sorted end
      };
    };
    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    # used by nixos-extra-modules automatically
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixos-generators,
      nixos-extra-modules,
      nix-topology,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./nix/agenix-rekey.nix
        ./nix/devshell.nix
        ./nix/globals.nix
        ./nix/pkgs.nix
        ./nix/patch.nix
        nix-topology.flakeModule
        nixos-extra-modules.modules.flake.default
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
                nixosConfigurations = self.nodes;
                decryptIdentity = ../keys/PatC.pub;
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
