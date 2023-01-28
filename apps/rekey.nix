{
  self,
  nixpkgs,
  ...
}: system:
with nixpkgs.lib; let
  pkgs = import nixpkgs {inherit system;};

  rekeyCommandForHost = hostName: hostAttrs: let
    secretPath = "/tmp/nix-rekey.d/${hostName}/";
    masterIdentities = strings.concatMapStrings (x: "-i ${x} ") hostAttrs.config.rekey.masterIdentityPaths;

    rekeyCommand = secretName: secretAttrs: let
      pubKeyStr = let
        key = hostAttrs.config.rekey.pubKey;
      in
        if isPath key
        then readFile key
        else key;
    in ''
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
      echo "[1;3mNo Identities set for host ${hostName}. Can not decrypt.\n\
      Make sure you set 'config.rekey.masterIdentityPaths'[m"
    ''
    else if
      let
        key = hostAttrs.config.rekey.pubKey;
      in
        isPath key && (! pathExists key)
    then ''
      echo "[1;3mNo public keys available for host ${hostName}. Can not decrypt.\n\
      Make sure the public keys are reachable by the building system'[m"
    ''
    else ''
         mkdir -p ${secretPath}
         # TODO
         ${concatStringsSep "\n" (mapAttrsToList rekeyCommand (hostAttrs.config.rekey.secrets))}

      nix run --extra-sandbox-paths /tmp/nix-rekey.d/ "${../.}#rekey-copy-secrets"
    '';

  rekeyScript = ''
    set -euo pipefail

    ${concatStringsSep "\n" (mapAttrsToList rekeyCommandForHost self.nixosConfigurations)}

  '';

  rekey-exe = pkgs.writeShellScript "rekey.sh" rekeyScript;

  rekey-copy-secretsForHost = hostName: hostAttrs: let
    secretFiles = mapAttrsToList (_: x: x.file) hostAttrs.config.rekey.secrets;
    drv = import ../modules/rekey-drv.nix pkgs secretFiles;
  in ''
    echo ${drv}
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
