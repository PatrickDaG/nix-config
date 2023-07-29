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
    ];
    env = [
      {
        name = "NIX_CONFIG";
        # Nix plugins braucht nix version 2.16
        # Nixpkgs hat aber aktuell 2.15 also main version
        # Daher der folgenda hack um zu verhindern das mein NixOS mit einer anderen nix version gebaut wird
        # als der intendeten
        value = ''
          plugin-files = ${(pkgs.nix-plugins.override {inherit (pkgs) nix;}).overrideAttrs rec {
            version = "10.0.0";

            src = pkgs.fetchFromGitHub {
              owner = "shlevy";
              repo = "nix-plugins";
              rev = version;
              hash = "sha256-7Lo+YxpiRz0+ZLFDvYMJWWK2j0CyPDRoP1wAc+OaPJY=";
            };
          }}/lib/nix/plugins
          extra-builtins-file = ${../nix}/extra-builtins.nix
        '';
      }
    ];

    devshell.startup.pre-commit.text = self.checks.${system}.pre-commit-check.shellHook;
  }
