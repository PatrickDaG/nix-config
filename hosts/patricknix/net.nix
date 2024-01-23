{config, ...}: {
  age.secrets.eduroam = {
    rekeyFile = ./secrets/iwd/eduroam.8021x.age;
    path = "/var/lib/iwd/eduroam.8021x";
  };
  age.secrets.simonWlan = {
    rekeyFile = ./. + "/secrets/iwd/=467269747a21426f78373539302048616e7373656e.psk.age";
    path = "/var/lib/=467269747a21426f78373539302048616e7373656e.psk";
  };
  age.secrets = {
    devoloog-psk.rekeyFile = ./secrets/iwd/devoloog-psk.age;
    devoloog-pass.rekeyFile = ./secrets/iwd/devoloog-pass.age;
    devoloog-sae19.rekeyFile = ./secrets/iwd/devoloog-sae19.age;
    devoloog-sae20.rekeyFile = ./secrets/iwd/devoloog-sae20.age;
  };
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
    # Add the VPN based route to my paperless instance to
    # etc/hosts
    extraHosts = ''
      10.0.0.1 paperless.lel.lol
    '';
  };

  systemd.network.networks = {
    "01-lan1" = {
      address = ["192.168.178.31/24"];
      gateway = ["192.168.178.1"];
      matchConfig.MACAddress = config.secrets.secrets.local.networking.lan1.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
      dns = ["1.1.1.1"];
      dhcpV4Config.RouteMetric = 10;
      dhcpV6Config.RouteMetric = 10;
    };
    "02-lan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.lan2.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
      dns = ["1.1.1.1"];
      dhcpV4Config.RouteMetric = 10;
      dhcpV6Config.RouteMetric = 10;
    };
    "01-wlan1" = {
      DHCP = "no";
      address = ["192.168.1.6/24"];
      gateway = ["192.168.1.2"];
      matchConfig.MACAddress = config.secrets.secrets.local.networking.wlan1.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
      dns = ["1.1.1.1"];
      dhcpV4Config.RouteMetric = 40;
      dhcpV6Config.RouteMetric = 40;
    };
  };
}
