{self, ...}: system:
with self.pkgs.${system};
  mkShell {
    name = "nix-config";
    packages = [
      # Nix
      cachix
      colmena
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

    shellHook = ''
      ${self.checks.${system}.pre-commit-check.shellHook}
    '';
  }
