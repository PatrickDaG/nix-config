_final: prev: {
  # Apparently some packages take a script argument from callPackage(e.g. mpv)
  # so we have to name this differently
  pat-scripts = {
    clone-term = prev.callPackage ./clone-term.nix { };
    update = prev.writeShellApplication {
      name = "update";
      runtimeInputs = [ ];
      text = ''
        nix flake update
        nim update-prs
      '';
    };
    git-dirty = prev.callPackage ./git-dirty.nix { };
  };
}
