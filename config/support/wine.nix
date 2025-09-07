{
  lib,
  minimal,
  inputs,
  ...
}:
lib.optionalAttrs (!minimal) {
  imports = [ inputs.nix-gaming.nixosModules.wine ];
  programs.wine = {
    enable = true;
    binfmt = true;
    ntsync = lib.trace "Enable once on linux 6.14" false;
  };
}
