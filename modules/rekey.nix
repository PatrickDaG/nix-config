{
  lib,
  config,
  pkgs,
  stdenv,
  options,
  ...
}: {
  # TODO add a with lib um mir die ganzen lib. zu ersparen
  config = let
    masterIdentities = lib.strings.concatMapStrings (x: "-i ${x} ") config.rekey.masterIdentityPaths;
    rekeyedSecrets = pkgs.stdenv.mkDerivation rec {
      pname = "age-rekey";
      version = "1.0.0";
      allSecrets = lib.mapAttrsToList (_: x: x.file) config.rekey.secrets;
      pubKeyStr =
        if builtins.isPath config.rekey.pubKey
        then builtins.readFile config.rekey.pubKey
        else config.rekey.pubKey;
      dontMakeSourceWriteable = 1;
      dontUnpack = true;
      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      installPhase = let
        pluginPaths = lib.strings.concatMapStrings (x: ":${x}/bin") config.rekey.plugins;

        rekeyCommand = secret: ''
                      echo "Rekeying secret ${secret}" >&2
                      ${pkgs.rage}/bin/rage ${masterIdentities} -d ${secret} \
                      | ${pkgs.rage}/bin/rage -r "${pubKeyStr}" -o "$out/${builtins.baseNameOf secret}" -e \
          || { echo 1 > "$out"/status; echo "disabled due to failure in rekey.nix" | ${pkgs.rage}/bin/rage -r "${pubKeyStr}" -o "$out/${builtins.baseNameOf secret}" -e ;}
        '';
      in ''
                 set -euo pipefail
                 mkdir $out
        echo 0 > "$out"/status

                 export PATH=$PATH${pluginPaths}
                 ${lib.concatStringsSep "\n" (map rekeyCommand allSecrets)}

      '';
    };
  in
    lib.mkIf (config.rekey.secrets != {}) {
      # Polkit rule to enable the build process to access the keys saved on a yubikey
      # This rule allows any user named nixbld<num> to accesst pcscd
      security.polkit.extraConfig = lib.mkIf (lib.elem pkgs.age-plugin-yubikey config.rekey.plugins) ''
        polkit.addRule(function(action, subject) {
        	if ((action.id == "org.debian.pcsc-lite.access_pcsc" || action.id == "org.debian.pcsc-lite.access_card") &&
        		subject.user.match(/^nixbld\d+$/)) {
        		return polkit.Result.YES;
        	}
        });
      '';

      environment.systemPackages = with pkgs; [
        rage
      ];

      age = {
        secrets = let
          newPath = x: "${rekeyedSecrets}/${builtins.baseNameOf x}";
        in
          builtins.mapAttrs (_:
            builtins.mapAttrs (name: value:
              if name == "file"
              then "${newPath value}"
              else value))
          config.rekey.secrets;
      };
      assertions = [
        {
          assertion = builtins.pathExists config.rekey.pubKey;
          message = "Did not find key file: ${config.rekey.pubKey}.
			Make sure your public key is available for rekeying.";
        }
        {
          assertion = config.rekey.masterIdentityPaths != [];
          message = "rekey.masterIdentityPaths must be set!";
        }
      ];
      warnings =
        lib.optional (builtins.any (x: !(lib.strings.hasSuffix ".pub" x || lib.strings.hasSuffix ".age" x)) config.rekey.masterIdentityPaths) ''
                 It seems at least one of your master masterIdentities files is not encrypted or not a public handle.
          Please make sure it does not contain any secret Information.
        ''
        ++ lib.optional (lib.toInt (builtins.readFile "${rekeyedSecrets}/status") == 1) ''
          Could not rekey. Might be due to a chicken/egg problem, then a retry will fix this.
        '';
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

    rekey.privKey = mkOption {
      type = types.str;
      description = ''
        The age private key part, corresponding to the public key set in "rekey.pubKey".
        Used by agenix for decryption.
        Preferably set this to your ed25519 host key.
      '';
      example = "/etc/ssh/ssh_host_ed25519_key";
    };

    rekey.masterIdentityPaths = mkOption {
      type = types.listOf types.path;
      description = ''
        A list of Identities used for decrypting your secrets before rekeying.
        **WARING this will end up in the nix-store**
        Only use yubikeys or encrypted age keys
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
