{
  config,
  lib,
  globals,
  ...
}:
let
  icfg = config.secrets.secrets.local.networking.interfaces.lan01;
in
{
  networking.hostId = config.secrets.secrets.local.networking.hostId;

  boot.initrd.systemd.network = {
    enable = true;
    networks = {
      inherit (config.systemd.network.networks) "lan01";
    };
  };

  systemd.network.networks = {
    "lan01" = {
      address = [
        icfg.hostCidrv4
        (lib.net.cidr.hostCidr 1 icfg.hostCidrv6)
      ];
      gateway = [ "fe80::1" ];
      routes = [
        { Destination = "172.31.1.1"; }
        {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        }
      ];
      matchConfig.MACAddress = icfg.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      linkConfig.RequiredForOnline = "routable";
    };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan01" ];
  meta.telegraf.availableMonitoringNetworks = [
    "internet"
  ];
  globals.wireguard.services-extern = {
    host = icfg.hostCidrv4;
    port = 51822;
    cidrv4 = "10.44.0.0/20";
    cidrv6 = "fd00:1766::/112";
    idFile = ../../ids.json;
    hosts.${config.node.name}.server = true;
  };
  networking.nftables.firewall.zones = {
    wg-services-extern.interfaces = [ "services-extern" ];
  };
  networking.nftables.firewall = {
    snippets.nnf-ssh.enable = lib.mkForce false;
    rules = {
      ssh = {
        from = [ "untrusted" ];
        to = [ "local" ];
        allowedTCPPorts = [ 22 ];
      };
      wireguard-services-extern = {
        from = [ "untrusted" ];
        to = [ "local" ];
        allowedUDPPorts = [
          globals.wireguard.services-extern.port
        ];
      };
      forward-services-wireguard = {
        from = [ "wg-services-extern" ];
        to = [ "wg-services-extern" ];
        verdict = "accept";
      };
    };
  };
}
