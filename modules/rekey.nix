{
  lib,
  config,
  pkgs,
  stdenv,
  options,
  ...
}: {
  config = with lib; let
    secretFiles = mapAttrsToList (_: x: x.file) config.rekey.secrets;
    drv = import ./rekey-drv.nix pkgs secretFiles;
  in
    mkIf (config.rekey.secrets != {}) {
      age = {
        secrets = let
          hostName = config.networking.hostName;
          secretPath = "${drv}/${hostName}/";
          newPath = x: "${secretPath}/${x}.age";
        in
          mapAttrs (name: value: value // {file = newPath name;}) config.rekey.secrets;
      };
    };

  options = with lib; {
    rekey.secrets = options.age.secrets;
    rekey.pubKey = mkOption {
      type = types.either types.path types.str;
      description = ''
        The age public key set as a recipient when rekeying.
        either a path to a public key file or a string public key
        **NEVER set this to a private key part**
        ~~This will end up in the nix store.~~
      '';
      example = /etc/ssh/ssh_host_ed25519_key.pub;
    };

    rekey.masterIdentityPaths = mkOption {
      type = types.listOf types.path;
      description = ''
        A list of Identities used for decrypting your secrets before rekeying.
        **WARING this will end up in the nix-store**
        Only use yubikeys or password encrypted age keys
      '';
    };

    rekey.plugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = ''
        A list of plugins that should be available in your path when rekeying.
      '';
      example = [pkgs.age-plugin-yubikey];
    };
  };
}
