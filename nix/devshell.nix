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
    commands = with pkgs; [
      {
        package =
          colmena.packages.${system}.colmena;
        help = "Apply nix configurations";
      }
      {
        package =
          alejandra;
        help = "Format nix code";
      }
      {
        package = statix;
        help = "Linter for nix";
      }
      {
        package = update-nix-fetchgit;
        help = "Update fetcher inside nix files";
      }
      {
        # nix plugins is currently build against nix version 2.16
        # official nix version is 2.15 but if we try to load plugins
        # it throws linking errors
        package = nixVersions.nix_2_16;
      }
    ];
    env = [
      {
        name = "NIX_CONFIG";
        value = ''
          plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
          extra-builtins-file = ${../nix}/extra-builtins.nix
        '';
      }
    ];

    devshell.startup.pre-commit.text = self.checks.${system}.pre-commit-check.shellHook;
  }
