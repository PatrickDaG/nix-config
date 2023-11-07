{
  lib,
  inputs,
  config,
  ...
}: let
  inherit
    (lib)
    mapAttrs
    assertMsg
    types
    mkOption
    mdDoc
    literalExpression
    ;
  # If the given expression is a bare set, it will be wrapped in a function,
  # so that the imported file can always be applied to the inputs, similar to
  # how modules can be functions or sets.
  constSet = x:
    if builtins.isAttrs x
    then (_: x)
    else x;

  rageImportEncrypted = assert assertMsg (builtins ? extraBuiltins.rageImportEncrypted) "The rageImportEncrypted extra plugin is not loaded";
    builtins.extraBuiltins.rageImportEncrypted;
  # This "imports" an encrypted .nix.age file
  importEncrypted = path:
    constSet (
      if builtins.pathExists path
      then rageImportEncrypted inputs.self.secretsConfig.masterIdentities path
      else {}
    );
  cfg = config.secrets;
in {
  options.secrets = {
    defineRageBuiltins = mkOption {
      default = true;
      type = types.bool;
      description = mdDoc ''
        Add nix plugins and the extra builtins file to the nix config
        Enabling this host to decrypt secret when deploying
      '';
    };

    secretFiles = mkOption {
      default = {};
      type = types.attrsOf types.path;
      example = literalExpression "{ local = ./secrets.nix.age; }";
      description = mdDoc ''
        Files containg secrets for this host.
        As these will end up in the nix store of the host use this for
        secrets that can be publicly known on the host but should be private
        in the repository
      '';
    };

    secrets = mkOption {
      readOnly = true;
      default =
        mapAttrs (_: x: importEncrypted x inputs) cfg.secretFiles;
      description = mdDoc ''
        the secrets decrypted from the secretFiles
      '';
    };
  };
  config.home-manager.sharedModules = [
    ({config, ...}: {
      options = {
        userSecretsFile = mkOption {
          default = ../users/${config._module.args.name}/secrets.nix.age;
          type = types.path;
          description = "The global secrets attribute that should be exposed to the user";
        };
        userSecrets = mkOption {
          readOnly = true;
          default = importEncrypted config.userSecretsFile inputs;
          type = types.unspecified;
          description = "User secrets";
        };
      };
    })
  ];
}
