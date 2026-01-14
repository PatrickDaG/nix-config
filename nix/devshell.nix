{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
    inputs.pre-commit-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit.settings.hooks.treefmt.enable = true;
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          keep-sorted.enable = true;
          shellcheck.enable = true;
        };
      };
      devshells.default = {
        packages = with pkgs; [
          # Nix
          nil
          inputs.nixp-meta.packages.x86_64-linux.nim-release

          # Misc
          shellcheck
          pre-commit
          rage
          #lixPackageSets.latest.lix
          nix
          nix-diff
          nix-update
        ];
        commands = [
          {
            package = config.treefmt.build.wrapper;
            help = "Format all files";
          }
          {
            package = pkgs.symlinkJoin {
              name = "locker";
              paths = [
                pkgs.scripts.unlock
                pkgs.scripts.lock
              ];
            };
          }
          {
            package = pkgs.scripts.update;
            help = "update nix configurations";
          }
          {
            package = pkgs.nix-tree;
            help = "Show nix closure tree";
          }
          {
            package = pkgs.nvd;
            help = "List package differences between systems";
          }
          # {
          #   package = pkgs.vulnix;
          #   help = "List vulnerabilities found in your system";
          # }
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
