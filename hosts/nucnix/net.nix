{
  config,
  lib,
  globals,
  ...
}:
let
  inherit (lib)
    flip
    mapAttrsToList
    mkMerge
    genAttrs
    attrNames
    ;
in
{
  imports = [
    ./hostapd.nix
    ./kea.nix
    ./forwarding.nix
  ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nftables.firewall.zones = mkMerge [
    {
      fritz.interfaces = [ "vlan-fritz" ];
      wg-services.interfaces = [ "services" ];
      adguard.ipv4Addresses = [
        (lib.net.cidr.host globals.services.adguardhome.ip globals.net.vlans.services.cidrv4)
      ];
    }
    (genAttrs (attrNames globals.net.vlans) (name: {
      interfaces = [ "lan-${name}" ];
    }))
  ];
  systemd.network.netdevs = mkMerge (
    [
      {
        "40-vlan-fritz" = {
          netdevConfig = {
            Name = "vlan-fritz";
            Kind = "vlan";
          };
          vlanConfig.Id = 2;
        };
      }
    ]
    ++ (flip mapAttrsToList globals.net.vlans (
      name:
      {
        id,
        ...
      }:
      {
        "40-vlan-${name}" = {
          netdevConfig = {
            Name = "vlan-${name}";
            Kind = "vlan";
          };
          vlanConfig.Id = id;
        };
        "50-macvlan-${name}" = {
          netdevConfig = {
            Name = "lan-${name}";
            Kind = "macvlan";
          };
          extraConfig = ''
            [MACVLAN]
            Mode=bridge
          '';
        };
      }
    ))
  );
  systemd.network.networks = mkMerge (
    [
      {
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
          matchConfig.Name = "lan01";
          networkConfig.LinkLocalAddressing = "no";
          vlan = [ "vlan-fritz" ];
        };
      }
    ]
    ++ (flip mapAttrsToList globals.net.vlans (
      name:
      {
        cidrv4,
        cidrv6,
        ...
      }:
      {

        "40-vlans".vlan = [ "vlan-${name}" ];
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
            (lib.net.cidr.hostCidr 1 cidrv4)
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
            { Prefix = cidrv6; }
          ];
        };
      }
    ))
  );
  networking.nftables.firewall = {
    snippets.nnf-ssh.enable = lib.mkForce false;
    rules = {
      mdns = {
        from = [ "home" ];
        to = [ "local" ];
        allowedUDPPorts = [ 5353 ];
      };
      ssh = {
        from = [
          "fritz"
          "home"
        ];
        to = [ "local" ];
        allowedTCPPorts = [ 22 ];
      };
      services = {
        from = [
          "home"
        ];
        to = [
          "services"
          "fritz"
        ];
        late = true;
        verdict = "accept";
      };
      dns = {
        from = [
          "home"
          "devices"
          "guests"
          "services"
        ];
        to = [ "adguard" ];
        allowedUDPPorts = [ 53 ];
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
      wireguard = {
        from = [ "services" ];
        to = [ "local" ];
        allowedUDPPorts = [ config.wireguard.services.server.port ];
      };
      # Forward traffic between participants
      forward-wireguard = {
        from = [ "wg-services" ];
        to = [ "wg-services" ];
        verdict = "accept";
      };
    };
  };
  wireguard.services.server = {
    host = lib.net.cidr.host 1 "10.99.20.0/24";
    reservedAddresses = [
      "10.42.0.0/20"
      "fd00:1764::/112"
    ];
    openFirewall = true;
  };
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
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
            (lib.net.cidr.hostCidr 1 globals.net.vlans.home.cidrv4)
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
          vlanConfig.Id = globals.net.vlans.home.id;
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
