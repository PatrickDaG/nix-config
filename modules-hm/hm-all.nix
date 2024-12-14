{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    mkOptionType
    types
    mkIf
    mkMerge
    ;
in
{
  options = {
    primaryUser = mkOption {
      description = "Home-manager primary Username";
      type = types.nullOr types.str;
      default = null;
    };
    hm = mkOption {
      description = "Home-manager options for the main user";
      type = mkOptionType {
        name = "Home-manager options for the main user";
        merge = _loc: defs: (map (x: x.value) defs);
      };
      default = { };
    };
    hm-all = mkOption {
      description = "Home-manager options for the primary User and root.";
      type = mkOptionType {
        name = "Home-manager options for the all users";
        merge = _loc: defs: (map (x: x.value) defs);
      };
      default = { };
    };
  };
  config.home-manager.users = mkMerge [
    (mkIf (config.primaryUser != null) {
      ${config.primaryUser} = {
        imports = config.hm ++ config.hm-all;
      };
    })
    {
      root = {
        imports = config.hm-all;
      };
    }
  ];
}
