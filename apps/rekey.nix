{
  self,
  nixpkgs,
  ...
}: system:
with nixpkgs.lib; let
  pkgs = import nixpkgs {inherit system;};

  rekeyCommandForHost = hostName: hostAttrs: let
    masterIdentities = strings.concatMapStrings (x: "-i ${x} ") hostAttrs.config.rekey.masterIdentityPaths;

    pubKeyStr = hostAttrs.config.rekey.pubKey;
    secretPath = "/tmp/nix-rekey.d/${builtins.hashString "sha1" pubKeyStr}/";

    rekeyCommand = secretName: secretAttrs: ''
      echo "Rekeying secret ${secretName} for host ${hostName}"
      echo "${secretAttrs.file}"
      ${pkgs.rage}/bin/rage ${masterIdentities} -d ${secretAttrs.file} \
      | ${pkgs.rage}/bin/rage -r "${pubKeyStr}" -o "${secretPath}/${secretName}.age" -e \
      || { echo "[1;3mCould not rekey secrets. Inserting dummy values[m" \
      ; echo "Invalide due to failure when rekeying." \
      | ${pkgs.rage}/bin/rage -r "${pubKeyStr}" -o "${secretPath}/${secretName}.age" -e ;}
    '';
  in
    if masterIdentities == ""
    then ''
      echo -e "[1;3mNo Identities set for host ${hostName}. Cannot decrypt.\n\
      Make sure you set 'config.rekey.masterIdentityPaths'[m"
    ''
    else if
      let
        key = hostAttrs.config.rekey.pubKey;
      in
        isPath key && (! pathExists key)
    then ''
      echo -e "[1;3mNo public keys available for host ${hostName}. Can not decrypt.\n\
      Make sure the public keys are reachable by the building system'[m"
    ''
    else ''
      mkdir -p ${secretPath}
      ${concatStringsSep "\n" (mapAttrsToList rekeyCommand hostAttrs.config.rekey.secrets)}
    '';

  rekeyScript = ''
    set -euo pipefail

    ${concatStringsSep "\n" (mapAttrsToList rekeyCommandForHost self.nixosConfigurations)}

    nix run --extra-sandbox-paths /tmp/nix-rekey.d/ "${../.}#rekey-copy-secrets"

  '';

  rekey-exe = pkgs.writeShellScript "rekey.sh" rekeyScript;

  rekey-copy-secretsForHost = hostName: hostAttrs: let
    drv = import ../modules/rekey-drv.nix pkgs hostAttrs.config;
  in ''
    echo "Copied secrets for ${hostName} to ${drv}"
  '';
  rekey-copy-secrets-exe = pkgs.writeShellScript "rekey-copy-secrets.sh" ''
    ${concatStringsSep "\n" (mapAttrsToList rekey-copy-secretsForHost self.nixosConfigurations)}
  '';
in {
  rekey = {
    type = "app";
    program = "${rekey-exe}";
  };
  rekey-copy-secrets = {
    type = "app";
    program = "${rekey-copy-secrets-exe}";
  };
}
