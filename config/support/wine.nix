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
    ntsync = true;
  };
}
