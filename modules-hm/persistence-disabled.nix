{ lib, ... }:
{
  options.home.persistence = lib.mkOption {
    description = "Ignored compatibility option for configurations without persistence";
    type = lib.types.mkOptionType {
      name = "ignored-home-persistence";
      description = "arbitrary ignored Home Manager persistence configuration";
      check = builtins.isAttrs;
      merge = _location: _definitions: { };
    };
    default = { };
    internal = true;
  };
}
