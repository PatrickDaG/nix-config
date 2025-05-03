{
  config,
  lib,
  globals,
  utils,
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
    ./kea.nix
    ./forwarding.nix
    ./mdns.nix
    ./ddclient.nix
  ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nftables.firewall.zones = mkMerge [
    {
      fritz.interfaces = [ "vlan-fritz" ];
      wg-services.interfaces = [ "services" ];
      printer.ipv4Addresses = [
        (lib.net.cidr.host 32 globals.net.vlans.devices.cidrv4)
      ];
      smb.ipv4Addresses = [
        (lib.net.cidr.host globals.services.samba.ip globals.net.vlans.home.cidrv4)
      ];
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
          networkConfig = {
            MACVLAN = "lan-${name}";
          };
        };
        "20-lan-${name}" = {
          address = [
            (lib.net.cidr.hostCidr 1 cidrv4)
            (lib.net.cidr.hostCidr 1 cidrv6)
          ];
          matchConfig.Name = "lan-${name}";
          networkConfig = {
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
        from = [
          "home"
          "services"
          "devices"
          "guests"
          "iot"
        ];
        to = [ "local" ];
        allowedUDPPorts = [ 5353 ];
      };
      fritz-home-bridge = {
        from = [
          "fritz"
        ];
        to = [ "home" ];
        verdict = "accept";
      };
      printer-smb = {
        from = [
          "printer"
          "fritz"
        ];
        to = [ "smb" ];
        allowedTCPPorts = [ 445 ];
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
          "fritz"
        ];
        to = [
          "iot"
          "services"
          "devices"
          "fritz"
        ];
        late = true;
        verdict = "accept";
      };
      dns = {
        from = [
          "home"
          "devices"
          "fritz"
          "guests"
          "services"
          "fritz"
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
      };
      wireguard-services = {
        from = [ "services" ];
        to = [ "local" ];
        allowedUDPPorts = [
          globals.wireguard.services.port
        ];
      };
      wireguard-monitor = {
        from = "all";
        to = [ "local" ];
        allowedUDPPorts = [
          globals.wireguard.monitoring.port
        ];
      };
      # Forward traffic between participants
      forward-services-swireguard = {
        from = [ "wg-services" ];
        to = [ "wg-services" ];
        verdict = "accept";
      };
      forward-monitoring-wireguard = {
        from = [ "wg-monitoring" ];
        to = [ "wg-monitoring" ];
        verdict = "accept";
      };
    };
  };
  globals.wireguard.services = {
    host = lib.net.cidr.host 1 globals.net.vlans.services.cidrv4;
    cidrv4 = "10.42.0.0/20";
    cidrv6 = "fd00:1764::/112";
    idFile = ../../ids.json;
    hosts.${config.node.name}.server = true;
  };
  globals.wireguard.monitoring = {
    host = "wg.${globals.domains.web}";
    port = 51821;
    cidrv4 = "10.43.0.0/20";
    cidrv6 = "fd00:1765::/112";
    idFile = ../../ids.json;
    hosts.${config.node.name}.server = true;
  };
  # Override the wg endpoint to not tunnel the traffic through the router
  networking.hosts.${lib.net.cidr.host 1 globals.net.vlans.services.cidrv4} = [
    "wg.${globals.domains.web}"
  ];

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
  systemd.services.nftables.after = flip mapAttrsToList globals.net.vlans (
    name: _: "sys-subsystem-net-devices-${utils.escapeSystemdPath "lan-${name}"}.device"
  );
  meta.telegraf.availableMonitoringNetworks = [
    "home"
  ];
}
