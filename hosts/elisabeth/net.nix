{
  config,
  lib,
  globals,
  ...
}:
{
  imports = [
    ./forwarding.nix
    ./ddclient.nix
  ];
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nftables.firewall.zones = {
    house.interfaces = [ "lan-house" ];
  };

  systemd.network.netdevs = {
    "50-macvlan-house" = {
      netdevConfig = {
        Name = "lan-house";
        Kind = "macvlan";
      };
      extraConfig = ''
        [MACVLAN]
        Mode=bridge
      '';
    };
  };
  systemd.network.networks = {
    "10-lan-house" = {
      matchConfig.Name = "lan01";
      # This interface should only be used from attached macvtaps.
      # So don't acquire a link local address and only wait for
      # this interface to gain a carrier.
      networkConfig.LinkLocalAddressing = "no";
      linkConfig.RequiredForOnline = "carrier";
      extraConfig = ''
        [Network]
        MACVLAN=lan-house
      '';
    };
    "20-lan-house" = {
      matchConfig.Name = "lan-house";
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        DHCP = "no";
      };
      gateway = [
        (lib.net.cidr.host 1 globals.net.vlans.house.cidrv4)
        (lib.net.cidr.host 1 globals.net.vlans.house.cidrv6)
      ];
      address = [
        (lib.net.cidr.hostCidr globals.services.elisabeth.ip globals.net.vlans.house.cidrv4)
        (lib.net.cidr.hostCidr globals.services.elisabeth.ip globals.net.vlans.house.cidrv6)
      ];
    };
  };
  networking.nftables.firewall = {
    snippets.nnf-ssh.enable = lib.mkForce false;
    rules = {
      ssh = {
        from = [
          "house"
        ];
        to = [ "local" ];
        allowedTCPPorts = [ 22 ];
      };
      mdns = {
        from = [ "house" ];
        to = [ "local" ];
        allowedUDPPorts = [ 5353 ];
      };
      wireguard-services = {
        from = [ "house" ];
        to = [ "local" ];
        allowedUDPPorts = [
          globals.wireguard.services.port
        ];
      };
      # Forward traffic between participants
      forward-services-wireguard = {
        from = [ "wg-services" ];
        to = [ "wg-services" ];
        verdict = "accept";
      };
    };
  };
  globals.wireguard.services = {
    host = lib.net.cidr.host globals.services.elisabeth.ip globals.net.vlans.house.cidrv4;
    cidrv4 = "10.42.0.0/20";
    cidrv6 = "fd00:1764::/112";
    idFile = ../../ids.json;
    hosts.${config.node.name}.server = true;
  };

  boot.initrd = {

    availableKernelModules = [
      "8021q"
    ];
    systemd.network = {
      enable = true;
      networks = {
        # redo the network cause the livesystem has macvlans
        "10-lan-house" = {
          DHCP = "yes";
          matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
          };
        };
      };
    };
  };
}
