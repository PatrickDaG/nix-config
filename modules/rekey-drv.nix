pkgs: config: (
  # Derivation to copy the rekeyd secrets for tmp to the nix store
  # Agenix will read them from the store for decryption
  pkgs.stdenv.mkDerivation rec {
    pname = "host-secrets";
    version = "1";
    description = "Rekeyed secrets for this host";
    # Set all keys and secrets as input so the derivation gets rebuild if any of them change
    pubKeyStr = config.rekey.pubKey;
    secretFiles = pkgs.lib.mapAttrsToList (_: x: x.file) config.rekey.secrets;

    dontMakeSourcesWriteable = true;
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
         cp -r /tmp/nix-rekey.d/${builtins.hashString "sha1" pubKeyStr}/. $out \
      || { echo "Warning Secrets not available. Maybe you forgot to run 'nix run .#rekey' to rekey them?"; exit 1; }
    '';
  }
)
