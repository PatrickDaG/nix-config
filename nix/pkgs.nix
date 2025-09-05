{
  inputs,
  self,
  lib,
  ...
}:
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
        config.permittedInsecurePackages = lib.trace "teamspeak böse" [
          "qtwebengine-5.15.19"
        ];
        overlays = (import ../pkgs inputs) ++ [
          inputs.nix-topology.overlays.default
          inputs.nixos-extra-modules.overlays.default
          inputs.devshell.overlays.default
          inputs.agenix-rekey.overlays.default
          inputs.nixvim.overlays.default
          inputs.niri.overlays.niri
          (_: prev: {
            # nix-plugins = prev.nix-plugins.override {
            #   nix = prev.lixPackageSets.latest.lix;
            # };
          })
        ];
      };

      legacyPackages = pkgs;
      inherit pkgs;
    };
}
