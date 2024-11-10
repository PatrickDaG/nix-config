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
      pkgs.stdenvNoCC.mkDerivation {
        name = "Nixpkgs with patches from open PRs";
        src = inputs.nixpkgs;
        dontConfigure = true;
        dontBuild = true;
        doCheck = false;
        dontFixup = true;
        installPhase = ''
          cp -r ./ $out
        '';
        patches =
          if builtins.pathExists ../patches then pkgs.lib.filesystem.listFilesRecursive ../patches else [ ];
      };
  };
}
