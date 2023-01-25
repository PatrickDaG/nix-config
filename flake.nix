{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.home-manager = {
	url = "github:nix-community/home-manager";
	# should use system nixpkgs instead of their own
	inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.agenix.url = "github:oddlama/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, agenix, ... }: let
      system = "x86_64-linux";
    in {nixosConfigurations.patricknix =
		nixpkgs.lib.nixosSystem {
			inherit system;
      modules = [
		./configuration.nix
		home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
		  }
		  agenix.nixosModule
	  ];
    };
  };
}
