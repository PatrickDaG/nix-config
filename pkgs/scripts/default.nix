_final: prev: {
  scripts = {
    usbguardw = prev.callPackage ./usbguardw.nix {};
  };
}
