{config, ...}: {
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
    wireless.iwd.enable = true;
    # Add the VPN based route to my paperless instance to
    # etc/hosts
    extraHosts = ''
      10.0.0.1 paperless.lel.lol
    '';
  };

  systemd.network.networks = {
    "01-lan1" = {
      address = ["192.168.178.31/24"];
      matchConfig.MACAddress = config.secrets.secrets.local.networking.lan1.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
      dns = ["9.9.9.9"];
      dhcpV4Config.RouteMetric = 10;
      dhcpV6Config.RouteMetric = 10;
    };
    "01-wlan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.wlan1.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
      # TODO: change dns to own when at home
      dns = ["9.9.9.9"];
      dhcpV4Config.RouteMetric = 40;
      dhcpV6Config.RouteMetric = 40;
    };
  };
  age.secrets.eduroam = {
    rekeyFile = ./secrets/iwd/eduroam.8021x.age;
    path = "/var/lib/iwd/eduroam.8021x";
  };
  age.secrets.devoloog = {
    rekeyFile = ./secrets/iwd/devolo-og.psk.age;
    path = "/var/lib/iwd/devolo-og.psk";
  };
}
