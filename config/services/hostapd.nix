{ globals, pkgs, ... }:
{
  microvm.devices = [
    {
      bus = "pci";
      path = "0000:01:00.0";
    }
  ];
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan-services" ];
  hardware.wirelessRegulatoryDatabase = true;
  systemd.network = {
    netdevs."40-wifi-home" = {
      netdevConfig = {
        Name = "br-home";
        Kind = "bridge";
      };
    };
    networks."10-home-bridge" = {
      matchConfig.Name = "lan-home";
      DHCP = "no";
      extraConfig = ''
        [Network]
        Bridge=br-home
      '';
    };
    networks."10-home-" = {
      matchConfig.Name = "br-home";
      DHCP = "yes";
    };
  };

  services.hostapd = {
    enable = true;
    radios.wlan1 = {
      band = "2g";
      countryCode = "DE";
      channel = 5;
      wifi4.capabilities = [
        "LDPC"
        "HT40+"
        "HT40-"
        "SHORT-GI-20"
        "SHORT-GI-40"
        "TX-STBC"
        "RX-STBC1"
      ];
      wifi5.capabilities = [
        "LDPC"
        "HT40+"
        "HT40-"
        "SHORT-GI-20"
        "SHORT-GI-40"
        "TX-STBC"
        "RX-STBC1"
      ];
      wifi6.enable = true;
      wifi7.enable = true;
      networks.wlan1 = {
        inherit (globals.hostapd) ssid;
        apIsolate = true;
        settings.vlan_file = "${pkgs.writeText "hostaps.vlans" ''
          10 wifi-home br-home
          50 wifi-guest br-guest
        ''}";
        authentication = {
          saePasswords = [
            {
              password = "lol";
              vlanid = 10;
            }
            {
              password = "lel";
              vlanid = 50;
            }
          ];
          pairwiseCiphers = [
            "CCMP"
            "GCMP"
            "GCMP-256"
          ];
          #enableRecommendedPairwiseCiphers = true;
        };
        bssid = "44:38:e8:db:a5:b5";
      };
    };
  };
}
