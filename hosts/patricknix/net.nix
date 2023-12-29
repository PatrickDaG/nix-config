{
  config,
  lib,
  pkgs,
  ...
}: {
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
        "37C3".settings = {
          Security = {
            EAP-Method = lib.writeText "PEAP";
            EAP-Identity = lib.writeText "anonymous@37C3";
            EAP-PEAP-CACert = lib.writeText (pkgs.writeText "ISRG_Root_X1.pem" ''
              -----BEGIN CERTIFICATE-----
              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
              -----END CERTIFICATE-----
            '');
            EAP-PEAP-ServerDomainMask = lib.writeText "radius.c3noc.net";
            EAP-PEAP-Phase2-Method = lib.writeText "MSCHAPV2";
            EAP-PEAP-Phase2-Identity = lib.writeText "37C3";
            EAP-PEAP-Phase2-Password = lib.writeText "37C3";
          };
          Settings.AutoConnnect = lib.writeText "true";
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
      DHCP = "yes";
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
