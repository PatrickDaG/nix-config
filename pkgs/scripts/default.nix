_final: prev: {
  scripts = {
    usbguardw = prev.callPackage ./usbguardw.nix { };
    clone-term = prev.callPackage ./clone-term.nix { };
    impermanence-o = prev.callPackage ./impermanence-orphan.nix { };
  };
}
