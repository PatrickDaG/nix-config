{
  config,
  globals,
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
          # make sure this doesn't contain any sets called one of
          # state | persist | panzer | bunker | renaultft
          shared ? [ ],
          vlans ? [ "services" ],
          ...
        }:
        {
          autostart = true;
          zfs =
            {
              "/state" = {
                pool = "rpool";
                dataset = "local/guests/${guestName}";
              };
              "/persist" = {
                pool = "rpool";
                dataset = "safe/guests/${guestName}";
              };
              "/panzer" = lib.mkIf enablePanzer {
                pool = "panzer";
                dataset = "safe/guests/${guestName}";
              };
              "/renaultft" = lib.mkIf enableRenaultFT {
                pool = "renaultft";
                dataset = "safe/guests/${guestName}";
              };
              # kinda not necesarry should be removed on next reimaging
              "/bunker" = lib.mkIf enableBunker {
                pool = "panzer";
                dataset = "bunker/guests/${guestName}";
              };
            }
            // lib.listToAttrs (
              lib.flip lib.map shared (
                { name, pool }:
                lib.nameValuePair "/${name}" {
                  inherit pool;
                  dataset = "safe/shared/${name}";
                }
              )
            );
          modules = [
            ../../config/basic
            ../../config/services/${guestName}.nix
            inputs.microvm.nixosModules.microvm-options
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
            inherit inputs minimal;
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
              inherit inputs minimal;
            };
          };
        };
    in
    { }
    # // mkContainer "ollama" {
    #   enableRenaultFT = true;
    # }

    // mkContainer "invidious" { }
    // mkContainer "ttrss" { }
    // mkContainer "firefly" { }
    // mkContainer "yourspotify" { }
    // mkContainer "blog" { }

    // mkContainer "grafana" { enablePanzer = true; }
    // mkContainer "vaultwarden" { }
    // mkContainer "homeassistant" {
      vlans = [
        "services"
        "devices"
        "iot"
      ];
    }
    // mkContainer "nextcloud" { enablePanzer = true; }
    // mkContainer "paperless" {
      shared = [
        {
          name = "paperless";
          pool = "panzer";
        }
      ];
    }
    // mkContainer "forgejo" { enablePanzer = true; }
    // mkMicrovm "immich" { enablePanzer = true; }
    // mkContainer "jellyfin" {
      shared = [
        {
          name = "jellyfin";
          pool = "renaultft";
        }
      ];
    }
    // mkContainer "samba" {
      enablePanzer = true;
      enableBunker = true;
      shared = [
        {
          name = "paperless";
          pool = "panzer";
        }
        {
          name = "jellyfin";
          pool = "renaultft";
        }
      ];
      vlans = [
        "home"
      ];
    };

  # Zigbee Dongle
  # This is a very bad idea.
  # Hopefully no one else adds any usb devices
  containers.homeassistant.extraFlags = [
    "--bind=/dev/ttyUSB0"
  ];
  containers.homeassistant.allowedDevices = [
    {
      modifier = "rw";
      node = "/dev/ttyUSB0";
    }
  ];
}
