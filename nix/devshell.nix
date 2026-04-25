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
          lixPackageSets.latest.lix
          nix-diff
          nix-update
        ];
        commands = [
          {
            package = config.treefmt.build.wrapper;
            help = "Format all files";
          }
          {
            package = pkgs.pat-scripts.update;
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
          {
            package = pkgs.dix;
            help = "List package differences between systems but *rust*";
          }
          # {
          #   package = pkgs.vulnix;
          #   help = "List vulnerabilities found in your system";
          # }
        ];
        env = [
          {
            name = "NIX_CONFIG";
            # This seems dangerous, as it allows any nix code that I eval to gain immediate code execution
            # However I think any nix code that I evaluate as part of my flake most likely can already gain
            # root-code execution by injecting stuff into activationScripts
            value = ''
              allow-unsafe-native-code-during-evaluation = true
            '';
          }
        ];

        devshell.startup.pre-commit.text = config.pre-commit.installationScript;
      };
    };
}
