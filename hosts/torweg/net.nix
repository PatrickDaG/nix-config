{
  config,
  lib,
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
}
