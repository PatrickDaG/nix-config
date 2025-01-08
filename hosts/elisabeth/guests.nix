{
  config,
  globals,
  stateVersion,
  inputs,
  lib,
  minimal,
  ...
}:
{

  guests =
    let
      mkGuest =
        guestName:
        {
          enablePanzer ? false,
          enableRenaultFT ? false,
          enableBunker ? false,
          enableSharedPaperless ? false,
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
          zfs."/panzer" = lib.mkIf enablePanzer {
            pool = "panzer";
            dataset = "safe/guests/${guestName}";
          };
          zfs."/renaultft" = lib.mkIf enableRenaultFT {
            pool = "renaultft";
            dataset = "safe/guests/${guestName}";
          };
          # kinda not necesarry should be removed on next reimaging
          zfs."/bunker" = lib.mkIf enableBunker {
            pool = "panzer";
            dataset = "bunker/guests/${guestName}";
          };
          zfs."/paperless" = lib.mkIf enableSharedPaperless {
            pool = "panzer";
            dataset = "bunker/shared/paperless";
          };
          modules = [
            ../../config/basic
            ../../config/services/${guestName}.nix
            {
              node.secretsDir = config.node.secretsDir + "/${guestName}";
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

      mkMicrovm = guestName: cfg: {
        ${guestName} = mkGuest guestName cfg // {
          backend = "microvm";
          microvm = {
            system = "x86_64-linux";
            interfaces.lan-services = { };
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
          ${guestName} = mkGuest guestName cfg // {
            backend = "container";
            container.macvlans = lib.flip map vlans (x: "lan-${x}:mv-${x}");
            extraSpecialArgs = {
              inherit (inputs.self) nodes globals;
              inherit (inputs.self.pkgs.x86_64-linux) lib;
              inherit inputs minimal stateVersion;
            };
          };
        };
    in
    { }
    // mkContainer "oauth2-proxy" { }
    // mkContainer "vaultwarden" { }
    // mkContainer "ddclient" { }
    // mkContainer "ollama" {
      enableRenaultFT = true;
    }
    // mkContainer "murmur" { }
    // mkContainer "homebox" { }
    // mkContainer "invidious" { }
    // mkContainer "ttrss" { }
    // mkContainer "firefly" { }
    // mkContainer "yourspotify" { }
    // mkContainer "netbird" { }
    // mkContainer "blog" { }
    // mkContainer "kanidm" { }
    // mkContainer "homeassistant" {
      vlans = [
        "services"
        "devices"
        "iot"
      ];
    }
    // mkContainer "nextcloud" { enablePanzer = true; }
    // mkContainer "paperless" { enableSharedPaperless = true; }
    // mkContainer "forgejo" { enablePanzer = true; }
    // mkMicrovm "immich" { enablePanzer = true; }
    // mkContainer "samba" {
      enablePanzer = true;
      enableRenaultFT = true;
      enableBunker = true;
      enableSharedPaperless = true;
      vlans = [
        "home"
      ];
    };
}
