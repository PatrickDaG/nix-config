pkgs: config: (
  pkgs.stdenv.mkDerivation rec {
    pname = "host-secrets";
    version = "1";
    description = "Rekeyed secrets for this host";
    pubKeyStr = let
      pubKey = config.rekey.pubKey;
    in
      if builtins.isPath pubKey
      then builtins.readFile pubKey
      else pubKey;

    secretFiles = pkgs.lib.mapAttrsToList (_: x: x.file) config.rekey.secrets;
    srcs = secretFiles;
    sourceRoot = ".";

    dontMakeSourcesWriteable = true;
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      cp -r /tmp/nix-rekey.d/${builtins.hashString "sha1" pubKeyStr}/. $out
    '';
  }
)
