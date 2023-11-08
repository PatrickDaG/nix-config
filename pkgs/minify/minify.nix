{path}: let
  flake = builtins.getFlake path;
in {
  erg = builtins.mapAttrs (name: value: builtins.mapAttrs (name: value: name) value.inputs) flake.inputs;
}
