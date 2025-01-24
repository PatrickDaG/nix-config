{
  config,
  stateVersion,
  globals,
  inputs,
  lib,
  minimal,
  ...
}:
let
  inherit (lib)
    listToAttrs
    flip
    nameValuePair
    ;
in
{
  guests =
    let
      mkGuest =
        guestName:
        {
          vlans ? [ "services" ],
          ...
        }:
        {
          autostart = true;
          zfs."/state" = {
            pool = "rpool";
            dataset = "local/guests/${guestName}";
          };
          zfs."/persist" = {
            pool = "rpool";
            dataset = "safe/guests/${guestName}";
          };
          modules = [
            ../../config/basic
            ../../config/services/${guestName}.nix
            {
              node.secretsDir = config.node.secretsDir + "/${guestName}";
              globals.services.${guestName}.host = "${config.node.name}-${guestName}";

              networking.hosts.${lib.net.cidr.host 1 globals.net.vlans.services.cidrv4} = [
                "wg.${globals.domains.web}"
              ];
              networking.nftables.firewall.zones.untrusted.interfaces = [ "mv-services" ];
              systemd.network.networks = lib.mkIf (globals.services.${guestName}.ip != null) (
                lib.listToAttrs (
                  lib.flip map vlans (
                    name:
                    lib.nameValuePair "10-mv-${name}" {
                      matchConfig.Name = "mv-${name}";
                      DHCP = lib.mkForce "no";
                      address = [
                        (lib.net.cidr.hostCidr globals.services.${guestName}.ip globals.net.vlans.${name}.cidrv4)
                        (lib.net.cidr.hostCidr globals.services.${guestName}.ip globals.net.vlans.${name}.cidrv6)
                      ];
                      gateway = lib.optionals globals.net.vlans.${name}.internet [
                        (lib.net.cidr.host 1 globals.net.vlans.${name}.cidrv4)
                        (lib.net.cidr.host 1 globals.net.vlans.${name}.cidrv6)
                      ];
                    }
                  )
                )
              );
            }
          ];
        };

      mkMicrovm =
        guestName:
        {
          vlans ? [ "services" ],
          ...
        }@cfg:
        {
          ${guestName} = mkGuest guestName cfg // {
            backend = "microvm";
            microvm = {
              system = "x86_64-linux";
              interfaces = listToAttrs (flip map vlans (x: (nameValuePair "mv-${x}" { hostLink = "lan-${x}"; })));
              baseMac = config.secrets.secrets.local.networking.interfaces.lan01.mac;
            };
            extraSpecialArgs = {
              inherit (inputs.self) nodes globals;
              inherit (inputs.self.pkgs.x86_64-linux) lib;
              inherit inputs minimal stateVersion;
            };
          };
        };

      mkContainer =
        guestName:
        {
          vlans ? [ "services" ],
          ...
        }@cfg:
        {
          ${guestName} = lib.mkMerge [
            (mkGuest guestName cfg)
            {
              backend = "container";
              container.macvlans = lib.flip map vlans (x: "lan-${x}:mv-${x}");
              extraSpecialArgs = {
                inherit (inputs.self) nodes globals;
                inherit (inputs.self.pkgs.x86_64-linux) lib;
                inherit inputs minimal stateVersion;
              };
            }
          ];
        };
    in
    { } // mkContainer "adguardhome" { } // mkContainer "nginx" { };
}
