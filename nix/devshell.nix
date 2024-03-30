{
  self,
  devshell,
  agenix-rekey,
  ...
}: system: let
  pkgs = self.pkgs.${system};
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
      nix
      nix-diff
    ];
    commands = [
      {
        package = pkgs.deploy;
        help = "build and deploy nix configurations";
      }
      {
        package = pkgs.minify;
        help = "build and deploy nix configurations";
      }
      {
        package = pkgs.agenix-rekey;
        help = "Edit and rekey repository secrets";
      }
      {
        package = pkgs.alejandra;
        help = "Format nix code";
      }
      {
        package = pkgs.statix;
        help = "Linter for nix";
      }
      {
        package = pkgs.deadnix;
        help = "Remove dead nix code";
      }
      {
        package = pkgs.nix-tree;
        help = "Show nix closure tree";
      }
      {
        package = pkgs.update-nix-fetchgit;
        help = "Update fetcher inside nix files";
      }
      {
        package = pkgs.nvd;
        help = "List package differences between systems";
      }
      {
        package = pkgs.vulnix;
        help = "List vulnerabilities found in your system";
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
