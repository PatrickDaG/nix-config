{ config, lib, ... }:
{
  age.generators.basic-auth =
    {
      pkgs,
      lib,
      decrypt,
      deps,
      ...
    }:
    lib.flip lib.concatMapStrings deps (
      {
        name,
        host,
        file,
      }:
      ''
        echo " -> Aggregating ␛[32m"${lib.escapeShellArg host}":␛[m␛[33m"${lib.escapeShellArg name}"␛[m" >&2
        ${decrypt} ${lib.escapeShellArg file} \
          | ${pkgs.apacheHttpd}/bin/htpasswd -niBC 12 ${lib.escapeShellArg host}"+"${lib.escapeShellArg name} \
          || die "Failure while aggregating basic auth hashes"
      ''
    );
  age.generators.argon2id =
    {
      pkgs,
      lib,
      decrypt,
      deps,
      ...
    }:
    let
      dep = builtins.head deps;
    in
    ''
      echo " -> Deriving argon2id hash from [32m"${lib.escapeShellArg dep.host}":[m[33m"${lib.escapeShellArg dep.name}"[m" >&2
      ${decrypt} ${lib.escapeShellArg dep.file} \
        | tr -d '\n' \
        | ${pkgs.libargon2}/bin/argon2 "$(${pkgs.openssl}/bin/openssl rand -base64 16)" -id -e \
        || die "Failure while generating argon2id hash"
    '';
  secrets.secretFiles =
    let
      local = config.node.secretsDir + "/secrets.nix.age";
    in
    lib.optionalAttrs (config.node.name != null && lib.pathExists local) { inherit local; };
}
