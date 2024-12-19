{ config, lib, ... }:
let
  vlans = {
    home = 10;
    services = 20;
    devices = 30;
    iot = 40;
    guests = 50;
  };
  inherit (lib) flip mapAttrsToList;
in
{
  imports =
    [
      ./hostapd.nix
      ./kea.nix
    ]
    ++ (flip mapAttrsToList vlans (
      name: id: {
        networking.nftables.firewall.zones.${name}.interfaces = [ "lan-${name}" ];

        systemd.network = {
          netdevs = {
            "40-vlan-${name}" = {
              netdevConfig = {
                Name = "vlan-${name}";
                Kind = "vlan";
              };
              vlanConfig.Id = id;
            };
            "50-mlan-${name}" = {
              netdevConfig = {
                Name = "lan-${name}";
                Kind = "macvlan";
              };
              extraConfig = ''
                [MACVLAN]
                Mode=bridge
              '';
            };
          };
          networks = {
            "10-vlan-${name}" = {
              matchConfig.Name = "vlan-${name}";
              # This interface should only be used from attached macvtaps.
              # So don't acquire a link local address and only wait for
              # this interface to gain a carrier.
              networkConfig.LinkLocalAddressing = "no";
              linkConfig.RequiredForOnline = "carrier";
              extraConfig = ''
                [Network]
                MACVLAN=lan-${name}
              '';
            };
            "20-lan-${name}" = {
              address = [
                (lib.net.cidr.hostCidr 1 "10.99.${toString id}.0/24")
              ];
              matchConfig.Name = "lan-${name}";
              networkConfig = {
                MulticastDNS = true;
                IPv6PrivacyExtensions = "yes";
                IPv4Forwarding = "yes";
                IPv6SendRA = true;
                IPv6AcceptRA = false;
                DHCPPrefixDelegation = true;
              };
              ipv6Prefixes = [
                { Prefix = "fd${toString id}::/64"; }
              ];
            };
          };
        };
      }
    ));
  networking.nftables.firewall = {
    snippets.nnf-ssh.enable = lib.mkForce false;
    rules = {
      ssh = {
        from = [
          "fritz"
          "home"
        ];
        to = [ "local" ];
        allowedTCPPorts = [ 22 ];
      };
      internet = {
        from = [
          "home"
          "devices"
          "guests"
          "services"
        ];
        to = [ "fritz" ];
        late = true;
        verdict = "accept";
        masquerade = true;
      };
    };
  };
  networking.nftables.firewall.zones.fritz.interfaces = [ "vlan-fritz" ];
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network = {
    netdevs."40-vlan-fritz" = {
      netdevConfig = {
        Name = "vlan-fritz";
        Kind = "vlan";
      };
      vlanConfig.Id = 2;
    };
    networks = {
      "10-lan-fritz" = {
        address = [
          (lib.net.cidr.hostCidr 2 "10.99.2.0/24")
        ];
        gateway = [ (lib.net.cidr.host 1 "10.99.2.0/24") ];
        matchConfig.Name = "vlan-fritz";
        networkConfig = {
          IPv6PrivacyExtensions = "yes";
        };
      };
    };

    networks."40-vlans" = {
      matchConfig.Name = "lan01";
      networkConfig.LinkLocalAddressing = "no";
      vlan = [
        "vlan-fritz"
        "vlan-home"
        "vlan-services"
        "vlan-devices"
        "vlan-iot"
        "vlan-guests"
      ];
    };
  };

  boot.initrd = {

    availableKernelModules = [
      "8021q"
    ];
    systemd.network = {
      enable = true;
      networks = {
        # redo the network cause the livesystem has macvlans
        "10-lanhome" = {
          address = [
            (lib.net.cidr.hostCidr 1 "10.99.10.0/24")
          ];
          matchConfig.Name = "vlan-home";
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
          };
        };
        # redo the network cause the livesystem has macvlans
        "10-lan-fritz" = {
          address = [
            (lib.net.cidr.hostCidr 2 "10.99.2.0/24")
          ];
          gateway = [ (lib.net.cidr.host 1 "10.99.2.0/24") ];
          matchConfig.Name = "vlan-fritz";
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
          };
        };
        "40-vlans" = {
          matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
          vlan = [
            "vlan-home"
            "vlan-fritz"
          ];
        };
      };
      netdevs = {
        "10-vlan-home" = {
          netdevConfig = {
            Name = "vlan-home";
            Kind = "vlan";
          };
          vlanConfig.Id = 10;
        };
        "10-vlan-fritz" = {
          netdevConfig = {
            Name = "vlan-fritz";
            Kind = "vlan";
          };
          vlanConfig.Id = 2;
        };
      };
    };
  };
}
