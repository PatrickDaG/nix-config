{
  lib,
  config,
  pkgs,
  stdenv,
  options,
  ...
}: {
  options = with lib; {
    rekey.secrets = options.age.secrets;
    rekey.pubKey = mkOption {
      type = types.coercedTo types.path builtins.readFile types.str;
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
  };

  config = with lib; let
    secretFiles = mapAttrsToList (_: x: x.file) config.rekey.secrets;
    drv = import ./rekey-drv.nix pkgs config;
  in
    mkIf (config.rekey.secrets != {}) {
      # export all secrets to agenix with rewritten path from rekey
      age.secrets = let
        newPath = x: "${drv}/${x}.age";
      in
        mapAttrs (name: value: value // {file = newPath name;}) config.rekey.secrets;
    };
}
