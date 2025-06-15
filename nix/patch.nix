{
  inputs,
  ...
}:
{
  flake = {
    nixpkgs-patched =
      let
        system = "x86_64-linux";
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      pkgs.applyPatches {
        src = inputs.nixpkgs;
        name = "nixpkgs-patched";
        patches =
          if builtins.pathExists ../patches then pkgs.lib.filesystem.listFilesRecursive ../patches else [ ];
      };
  };
}
