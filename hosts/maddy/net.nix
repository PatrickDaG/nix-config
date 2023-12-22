{config, ...}: {
  networking.hostId = config.secrets.secrets.local.networking.hostId;
  networking.domain = config.secrets.secrets.global.domains.mail;

  boot.initrd.systemd.network = {
    enable = true;
    networks = {inherit (config.systemd.network.networks) "lan01";};
  };

  systemd.network.networks = {
    "lan01" = let
      icfg = config.secrets.secrets.local.networking.interfaces.lan01;
    in {
      address = [
        icfg.hostCidrv4
        icfg.hostCidrv6
      ];
      gateway = ["fe80::1"];
      routes = [
        {routeConfig = {Destination = "172.31.1.1";};}
        {
          routeConfig = {
            Gateway = "172.31.1.1";
            GatewayOnLink = true;
          };
        }
      ];
      matchConfig.MACAddress = icfg.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
