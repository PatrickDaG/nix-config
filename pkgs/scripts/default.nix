_final: prev: {
  scripts = {
    clone-term = prev.callPackage ./clone-term.nix { };
    deploy = prev.writeShellApplication {
      name = "deploy";
      runtimeInputs = [ prev.nvd ];
      text = builtins.readFile ./deploy.sh;
    };
    build = prev.writeShellApplication {
      name = "build";
      runtimeInputs = [ prev.nix-output-monitor ];
      text = builtins.readFile ./build.sh;
    };
    update = prev.writeShellApplication {
      name = "update";
      runtimeInputs = [ ];
      text = ''
        nix flake update
        nixp-meta update-prs
      '';
    };
  };
}
