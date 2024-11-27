{
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

}
