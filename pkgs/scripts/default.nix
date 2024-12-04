_final: prev: {
  scripts = {
    clone-term = prev.callPackage ./clone-term.nix { };
    unlock = prev.writeShellApplication {
      name = "unlock-builders";
      runtimeInputs = [ ];
      text = builtins.readFile ./unlock.sh;
    };
    lock = prev.writeShellApplication {
      name = "lock-builders";
      runtimeInputs = [ ];
      text = builtins.readFile ./lock.sh;
    };
    update = prev.writeShellApplication {
      name = "update";
      runtimeInputs = [ ];
      text = ''
        nix flake update
        nim update-prs
      '';
    };
  };
}
