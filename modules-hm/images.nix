{
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkMerge
    attrNames
    flip
    filterAttrs
    mkIf
    mkOption
    types
    removeSuffix
    hasPrefix
    mapAttrs'
    listToAttrs
    ;
in {
  home-manager.sharedModules = [
    {
      options.images = {
        enable = mkEnableOption "Enable images";
        images = mkOption {
          type = types.attrsOf types.path;
          readOnly = true;
          default = flip mapAttrs' (filterAttrs (n: _: hasPrefix "images-" n) config.age.secrets) (
            name: value: {
              inherit (value) name;
              value = value.path;
            }
          );
        };
      };
    }
  ];

  imports = [
    (
      {config, ...}: {
        age.secrets = mkMerge (
          flip map
          (attrNames config.home-manager.users)
          (
            user:
              mkIf config.home-manager.users.${user}.images.enable (
                listToAttrs (flip map (attrNames (filterAttrs (_: type: type == "regular") (builtins.readDir ../secrets/img)))
                  (
                    file: {
                      name = "images-${user}-${file}";
                      value = {
                        name = removeSuffix ".age" file;
                        rekeyFile = ../secrets/img/${file};
                        owner = user;
                        group = user;
                      };
                    }
                  ))
              )
          )
        );
      }
    )
  ];
}
