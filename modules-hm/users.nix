{ config, lib, ... }:
{
  options.hm = lib.mkOption {
    description = "NixOS-dependent Home Manager options for Patrick";
    type = lib.types.mkOptionType {
      name = "NixOS-dependent Home Manager options for Patrick";
      merge = _loc: defs: map (x: x.value) defs;
    };
    default = { };
  };

  config.home-manager.users.patrick.imports = config.hm;
}
