{
  config,
  pkgs,
  ...
}:
{
  environment.persistence."/state".directories = [
    "/var/lib/iwd"
    "/etc/mullvad-vpn"
  ];
  age.secrets.eduroam = {
    rekeyFile = ../patricknix/secrets/iwd/eduroam.8021x.age;
    path = "/var/lib/iwd/eduroam.8021x";
  };
  age.secrets.wg-priv-key = {
    rekeyFile = ../patricknix/secrets/wg-mpi-priv-key.age;
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [
    "lan01"
    "lan02"
    "wlan01"
  ];
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
    wireless.iwd = {
      enable = true;
    };
    wg-quick.interfaces.wg-mpi = {
      address = [
        "10.100.202.62/32"
        "2a02:d480:a40:1:2000:0:202:62/128"
      ];
      dns = [
        "10.100.1.25"
        "10.100.1.26"
        "10.100.1.27"
        "mpi-sp.org"
      ];
      mtu = 1380;
      autostart = false;
      privateKeyFile = config.age.secrets.wg-priv-key.path;
      peers = [
        {
          publicKey = "ZufCkzh6+NS2Fs2GnlAaG95U900oC+gUp77rZLcG4wU=";
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          endpoint = "141.5.46.36:51820";
          persistentKeepalive = 20;
        }
      ];
    };
  };

  systemd.network.networks = {
    "01-lan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
      };
      dhcpV4Config.RouteMetric = 10;
      dhcpV6Config.RouteMetric = 10;
    };
    "02-lan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan02.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
      };
      dhcpV4Config.RouteMetric = 10;
      dhcpV6Config.RouteMetric = 10;
    };
    "01-wlan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.wlan01.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
      };
      dhcpV4Config.RouteMetric = 40;
      dhcpV6Config.RouteMetric = 40;
    };
  };
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  services.firezone.gui-client = {
    enable = true;
    name = config.node.name;
  };
}
