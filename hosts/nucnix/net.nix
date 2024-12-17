{ config, lib, ... }:
{
  imports = [ ./hostapd.nix ];
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network = {
    networks = {
      "10-lan01" = {
        address = [
          (lib.net.cidr.hostCidr config.secrets.secrets.global.net.ips.${config.node.name}
            config.secrets.secrets.global.net.privateSubnetv4
          )
        ];
        gateway = [ (lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnetv4) ];
        #matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
        matchConfig.Name = "lan";
        dhcpV6Config.UseDNS = false;
        dhcpV4Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;
        networkConfig = {
          MulticastDNS = true;
        };
      };
    };
    netdevs."40-vlan-fritz" = {
      netdevConfig = {
        Name = "vlan-fritz";
        Kind = "vlan";
      };
      vlanConfig.Id = 2;
    };
    netdevs."40-vlan-home" = {
      netdevConfig = {
        Name = "vlan-home";
        Kind = "vlan";
      };
      vlanConfig.Id = 10;
    };

    netdevs."40-vlan-services" = {
      netdevConfig = {
        Name = "vlan-services";
        Kind = "vlan";
      };
      vlanConfig.Id = 20;
    };

    netdevs."40-vlan-devices" = {
      netdevConfig = {
        Name = "vlan-devices";
        Kind = "vlan";
      };
      vlanConfig.Id = 30;
    };

    netdevs."40-vlan-iot" = {
      netdevConfig = {
        Name = "vlan-iot";
        Kind = "vlan";
      };
      vlanConfig.Id = 40;
    };

    netdevs."40-vlan-guests" = {
      netdevConfig = {
        Name = "vlan-guests";
        Kind = "vlan";

      };
      vlanConfig.Id = 50;
    };

    networks."40-vlans" = {
      matchConfig.Name = "lan01";
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
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan" ];

  # To be able to ping containers from the host, it is necessary
  # to create a macvlan on the host on the VLAN 1 network.
  networking.macvlans.lan = {
    interface = "vlan-home";
    mode = "bridge";
  };

  boot.initrd = {

    availableKernelModules = [
      "8021q"
    ];
    systemd.network = {
      enable = true;
      networks = {
        # redo the network cause the livesystem has macvlans
        "10-lan01" = {
          address = [
            (lib.net.cidr.hostCidr config.secrets.secrets.global.net.ips.${config.node.name}
              config.secrets.secrets.global.net.privateSubnetv4
            )
          ];
          gateway = [ (lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnetv4) ];
          matchConfig.Name = "vlan-home";
          dhcpV6Config.UseDNS = false;
          dhcpV4Config.UseDNS = false;
          ipv6AcceptRAConfig.UseDNS = false;
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
            MulticastDNS = true;
          };
        };
      };
      netdevs."10-vlan-home" = {
        netdevConfig = {
          Name = "vlan-home";
          Kind = "vlan";

        };
        vlanConfig.Id = 10;
      };

      networks."40-vlans" = {
        matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
        vlan = [
          "vlan-home"
        ];
      };
    };
  };
}
