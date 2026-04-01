{
  inputs,
  config,
  self,
  ...
}:
{
  node.path = ../. + "/hosts";
  node.nixpkgs = self.nixpkgs-patched;

  imports = [
    (
      { lib, flake-parts-lib, ... }:
      flake-parts-lib.mkTransposedPerSystemModule {
        name = "pkgs";
        file = ./pkgs.nix;
        option = lib.mkOption { type = lib.types.unspecified; };
      }
    )
    (
      { lib, flake-parts-lib, ... }:
      flake-parts-lib.mkTransposedPerSystemModule {
        name = "pkgsCuda";
        file = ./pkgs.nix;
        option = lib.mkOption { type = lib.types.unspecified; };
      }
    )
  ];

  perSystem =
    { pkgs, system, ... }:
    {
      _module.args.pkgs = import config.node.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = (import ../pkgs inputs) ++ [
          inputs.nix-topology.overlays.default
          inputs.nixos-extra-modules.overlays.default
          inputs.devshell.overlays.default
          inputs.nixvim.overlays.default
          inputs.niri.overlays.niri
          inputs.firefox-addons.overlays.default
          inputs.llm-agents.overlays.default
          (_: _prev: {
            # nix-plugins = prev.nix-plugins.override {
            #   nix = prev.lixPackageSets.latest.lix;
            # };
          })
        ];
      };
      pkgsCuda = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };

      legacyPackages = pkgs;
      inherit pkgs;
    };
}
