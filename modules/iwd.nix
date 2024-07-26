{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.networking.wireless.iwd =
    let
      inherit (lib)
        mkOption
        literalExample
        types
        hasAttrByPath
        ;
    in
    {
      networks = mkOption {
        default = { };
        example = literalExample ''
          { "karlsruhe.freifunk.net" = {};
          };
        '';

        description = ''
          Declarative configuration of wifi networks for
          <citerefentry><refentrytitle>iwd</refentrytitle><manvolnum>8</manvolnum></citerefentry>.

          All networks will be stored in
          <literal>/var/lib/iwd/&lt;name&gt;.&lt;type&gt;</literal>.

          Since each network is stored in its own file, declarative networks can be used in an
          environment with imperatively added networks via
          <citerefentry><refentrytitle>iwctl</refentrytitle><manvolnum>1</manvolnum></citerefentry>.
        '';

        type = types.attrsOf (
          types.submodule (
            { config, ... }:
            {
              config.kind =
                if
                  (hasAttrByPath [
                    "Security"
                    "Passphrase"
                  ] config.settings)
                then
                  "psk"
                else if !(hasAttrByPath [ "Security" ] config.settings) then
                  "open"
                else
                  "8021x";

              options = {
                kind = mkOption {
                  type = types.enum [
                    "open"
                    "psk"
                    "8021x"
                  ];
                  description = "The type of network. This will determine the file ending. The module will try to determine this automatically so this should only be set when the heuristics fail.";
                };
                settings = mkOption {
                  type =
                    with types;
                    (attrsOf (
                      attrsOf (oneOf [
                        str
                        path
                      ])
                    ));
                  description = ''
                    Contents of the iwd config file for this network
                    The lowest level values should be files, that will be read into the config files
                  '';
                  default = { };
                };
              };
            }
          )
        );
      };
    };

  config =
    let
      inherit (lib)
        mkIf
        flip
        mapAttrsToList
        concatStringsSep
        ;
      cfg = config.networking.wireless.iwd;

      encoder = pkgs.writeScriptBin "encoder" ''
        #! ${pkgs.runtimeShell} -e

        # Extract file-ext from network names
        ext="$(sed -re 's/.*\.(8021x|open|psk)$/\1/' <<< "$*")"
        to_enc="$(sed -re "s/(.*)\.$ext/\1/g" <<< "$*")"

        # Encode ssid (excluding file-extensio) as base64 if needed
        [[ "$to_enc" =~ ^[[:alnum:]]+$ ]] && { echo "$to_enc.$ext"; exit 0; }
        echo "=$(printf "$to_enc" | ${pkgs.unixtools.xxd}/bin/xxd -pu).$ext"
      '';
    in
    mkIf cfg.enable {
      systemd.services.iwd = mkIf (cfg.networks != { }) {
        path = [ encoder ];
        preStart =
          let
            dataDir = "/var/lib/iwd";
          in
          ''
            # Create config files for declaratively defined networks in the NixOS config.
            ${concatStringsSep "\n" (
              flip mapAttrsToList cfg.networks (
                network: config: ''
                  filename=${dataDir}/"$(encoder '${network}.${config.kind}')"
                  touch "$filename"
                  cat >$filename <<EOF
                  ${concatStringsSep "\n" (
                    flip mapAttrsToList config.settings (
                      toplevel: config: ''
                        [${toplevel}]
                        ${concatStringsSep "\n" (
                          flip mapAttrsToList config (
                            name: value: ''
                              ${name}=$(<${value})
                            ''
                          )
                        )}
                      ''
                    )
                  )}
                  EOF
                ''
              )
            )}
          '';
      };
    };
}
