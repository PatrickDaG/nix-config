{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  nix = {
    enable = true;
    package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      p.flake = inputs.nixpkgs;
      pkgs.flake = inputs.nixpkgs;
      templates.flake = inputs.templates;
      t.flake = inputs.templates;
    };
  };
}
