{ inputs, self, ... }:
{
  imports = [
    (
      { lib, flake-parts-lib, ... }:
      flake-parts-lib.mkTransposedPerSystemModule {
        name = "pkgs";
        file = ./pkgs.nix;
        option = lib.mkOption { type = lib.types.unspecified; };
      }
    )
  ];

  perSystem =
    { pkgs, system, ... }:
    {
      _module.args.pkgs = import self.nixpkgs-patched {
        inherit system;
        config.allowUnfree = true;
        overlays = (import ../pkgs inputs) ++ [
          inputs.nix-topology.overlays.default
          inputs.nixos-extra-modules.overlays.default
        ];
      };

      inherit pkgs;
    };
}
