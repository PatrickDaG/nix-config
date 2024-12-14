{ config, lib, ... }:
{
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network.networks = {
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
  boot.initrd.systemd.network = {
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
        matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
        dhcpV6Config.UseDNS = false;
        dhcpV4Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;
        networkConfig = {
          IPv6PrivacyExtensions = "yes";
          MulticastDNS = true;
        };
      };
    };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan" ];

  # To be able to ping containers from the host, it is necessary
  # to create a macvlan on the host on the VLAN 1 network.
  networking.macvlans.lan = {
    interface = "lan01";
    mode = "bridge";
  };
}
