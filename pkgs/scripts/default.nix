_final: prev: {
  # Apparently some packages take a script argument from callPackage(e.g. mpv)
  # so we have to name this differently
  pat-scripts = {
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
