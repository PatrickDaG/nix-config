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
    drv = import ./rekey-drv.nix pkgs config;
  in
    mkIf (config.rekey.secrets != {}) {
	  # export all secrets to agenix with rewritten path from rekey
      age = {
        secrets = let
          secretPath = "${drv}/";
          newPath = x: "${secretPath}/${x}.age";
        in
          mapAttrs (name: value: value // {file = newPath name;}) config.rekey.secrets;
      };

      # Warn if rekey has to been executed
	  # use the drvPath to prevent nix from building the derivation in this step
	  # drvPath is not outPath so this warning does not work
	  # to fix it you would need some kind of way to access the outPath without evaluating the derivation
      #warnings = optional ( ! pathExists (removeSuffix ".drv" drv.drvPath)) ''
	  #  Path ${drv.drvPath}
      #  Rekeyed secrets not available.
      #  Maybe you forgot to run "nix run '.#rekey'" to rekey them?
      #'';
    };

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
}
