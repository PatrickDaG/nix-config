{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
    inputs.pre-commit-hooks.flakeModule
  ];

  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit.settings.hooks = {
        nixfmt-rfc-style = {
          enable = true;
        };
        deadnix.enable = true;
        statix.enable = true;
      };
      formatter = pkgs.nixfmt-rfc-style;
      devshells.default = {
        packages = with pkgs; [
          # Nix
          nil
          inputs.nixp-meta.packages.x86_64-linux.nixp-meta-release

          # Misc
          shellcheck
          pre-commit
          rage
          nix
          nix-diff
          nix-update
        ];
        commands = [
          {
            package = pkgs.deploy;
            help = "build and deploy nix configurations";
          }
          {
            package = pkgs.nixfmt-rfc-style;
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

        devshell.startup.pre-commit.text = config.pre-commit.installationScript;
      };
    };
}
