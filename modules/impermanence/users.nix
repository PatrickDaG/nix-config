{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    flip
    mapAttrs
    attrNames
    mkOption
    types
    mkMerge
    isAttrs
    ;
in {
  # Expose a home manager module for each user that allows extending
  # environment.persistence.${sourceDir}.users.${userName} simply by
  # specifying home.persistence.${sourceDir} in home manager.
  home-manager.sharedModules = [
    {
      options.home.persistence = mkOption {
        description = "Additional persistence config for the given source path";
        default = {};
        type = types.attrsOf (types.submodule {
          options = {
            files = mkOption {
              description = "Additional files to persist via NixOS impermanence.";
              type = types.listOf (types.either types.attrs types.str);
              default = [];
            };

            directories = mkOption {
              description = "Additional directories to persist via NixOS impermanence.";
              type = types.listOf (types.either types.attrs types.str);
              default = [];
            };
          };
        });
      };
    }
  ];

  # For each user that has a home-manager config, merge the locally defined
  # persistence options that we defined above.
  imports = let
    mkUserFiles = map (x:
      {parentDirectory.mode = "700";}
      // (
        if isAttrs x
        then x
        else {file = x;}
      ));
    mkUserDirs = map (x:
      {mode = "700";}
      // (
        if isAttrs x
        then x
        else {directory = x;}
      ));
  in [
    {
      environment.persistence = mkMerge (
        flip map
        (attrNames config.home-manager.users)
        (
          user: let
            hmUserCfg = config.home-manager.users.${user};
          in
            flip mapAttrs hmUserCfg.home.persistence
            (_: sourceCfg: {
              users.${user} = {
                # This needs to be set for allo users with non
                # standart home (not /home/<userName>
                # due to nixpkgs it
                # can't be deduced from homeDirectory
                # as there will be infinite recursion
                # If this setting is forgotten there
                # are assertions in place warning you
                home =
                  {
                    root = "/root";
                  }
                  .${user}
                  or "/home/${user}";
                files = mkUserFiles sourceCfg.files;
                directories = mkUserDirs sourceCfg.directories;
              };
            })
        )
      );
    }
  ];
}
