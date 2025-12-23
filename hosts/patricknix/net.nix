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
    rekeyFile = ./secrets/iwd/eduroam.8021x.age;
    path = "/var/lib/iwd/eduroam.8021x";
  };
  age.secrets = {
    devoloog-psk.rekeyFile = ./secrets/iwd/devoloog-psk.age;
    devoloog-pass.rekeyFile = ./secrets/iwd/devoloog-pass.age;
    devoloog-sae19.rekeyFile = ./secrets/iwd/devoloog-sae19.age;
    devoloog-sae20.rekeyFile = ./secrets/iwd/devoloog-sae20.age;
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
      networks = {
        devolo-og.settings = {
          Security = {
            PreSharedKey = config.age.secrets.devoloog-psk.path;
            Passphrase = config.age.secrets.devoloog-pass.path;
            SAE-PT-Group19 = config.age.secrets.devoloog-sae19.path;
            SAE-PT-Group20 = config.age.secrets.devoloog-sae20.path;
          };
        };
      };
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
    name = "patricknix";
  };
}
