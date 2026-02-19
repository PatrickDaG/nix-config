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
          ...
        }:
        {
          autostart = true;
          zfs = {
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

              networking.nftables.firewall.zones.untrusted.interfaces = [ "mv-home" ];
              systemd.network.networks = lib.mkIf (globals.services.${guestName}.ip != null) {
                "10-mv-house" = {
                  matchConfig.Name = "mv-house";
                  DHCP = lib.mkForce "no";
                  address = [
                    (lib.net.cidr.hostCidr globals.services.${guestName}.ip globals.net.vlans.house.cidrv4)
                    (lib.net.cidr.hostCidr globals.services.${guestName}.ip globals.net.vlans.house.cidrv6)
                  ];
                  gateway = lib.optionals globals.net.vlans.house.internet [
                    (lib.net.cidr.host 1 globals.net.vlans.house.cidrv4)
                    (lib.net.cidr.host 1 globals.net.vlans.house.cidrv6)
                  ];
                };
              };
            }
          ];
        };

      mkMicrovm = guestName: cfg: {
        ${guestName} = mkGuest guestName cfg // {
          backend = "microvm";
          microvm = {
            system = "x86_64-linux";
            interfaces.lan-house = { };
            baseMac = config.secrets.secrets.local.networking.interfaces.lan01.mac;
          };
          extraSpecialArgs = {
            inherit (inputs.self) nodes globals;
            inherit (inputs.self.pkgs.x86_64-linux) lib;
            inherit inputs minimal;
          };
        };
      };

      mkContainer = guestName: cfg: {
        ${guestName} = mkGuest guestName cfg // {
          backend = "container";
          container.macvlans = [ "lan-house:mv-house" ];
          extraSpecialArgs = {
            inherit (inputs.self) nodes globals;
            inherit (inputs.self.pkgs.x86_64-linux) lib;
            inherit inputs minimal;
          };
        };
      };
    in
    { }
    // mkContainer "personal" { }
    // mkContainer "vaultwarden" { }
    // mkContainer "nextcloud" { enablePanzer = true; }
    // mkContainer "forgejo" { enablePanzer = true; }
    // mkMicrovm "immich" { enablePanzer = true; }
    // mkContainer "paperless" {
      shared = [
        {
          name = "paperless";
          pool = "panzer";
        }
      ];
    }
    // mkContainer "jellyfin" {
      shared = [
        {
          name = "jellyfin";
          pool = "renaultft";
        }
      ];
    }
    // mkContainer "grafana" { enablePanzer = true; }
    // mkContainer "homeassistant" {
    }
    // mkContainer "firezone-gateway" { }
    // mkContainer "nginx" { }
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
    };

  containers.firezone-gateway.enableTun = true;
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
