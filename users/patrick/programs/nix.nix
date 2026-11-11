{ inputs, pkgs, ... }:
{
  nix = {
    enable = true;
    package = pkgs.lixPackageSets.latest.lix;
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      p.flake = inputs.nixpkgs;
      pkgs.flake = inputs.nixpkgs;
      templates.flake = inputs.templates;
      t.flake = inputs.templates;
    };
  };
}
