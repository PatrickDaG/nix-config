{
  self,
  nixpkgs,
  colmena,
  devshell,
  ...
}: system: let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [devshell.overlays.default];
  };
in
  pkgs.devshell.mkShell {
    name = "nix-config";
    packages = with pkgs; [
      # Nix
      cachix
      colmena.packages.${system}.colmena
      alejandra
      statix
      update-nix-fetchgit
      nil

      # Lua
      stylua
      (luajit.withPackages (p: with p; [luacheck]))
      lua-language-server

      # Misc
      shellcheck
      pre-commit
      rage
    ];

    devshell.startup.pre-commit.text = self.checks.${system}.pre-commit-check.shellHook;
  }
