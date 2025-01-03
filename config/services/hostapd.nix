{
  globals,
  pkgs,
  lib,
  ...
}:
{
  microvm.devices = [
    {
      bus = "pci";
      path = "0000:01:00.0";
    }
  ];
  hardware.firmware = with pkgs; [
    linux-firmware
    intel2200BGFirmware
  ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nftables.firewall.zones.untrusted.interfaces = [
    "mv-home"
    "br-home"
  ];
  hardware.wirelessRegulatoryDatabase = true;
  systemd.network = {
    netdevs."40-br-home" = {
      netdevConfig = {
        Name = "br-home";
        Kind = "bridge";
      };
    };
    networks."10-mv-home" = {
      networkConfig = {
        LinkLocalAddressing = "no";
        IPv6AcceptRA = lib.mkForce false;
        Bridge = "br-home";
      };
      address = lib.mkForce [ ];
      gateway = lib.mkForce [ ];
      DHCP = "no";
    };
    networks."10-home" = {
      matchConfig.Name = "br-home";
      DHCP = "no";
      address = [ "10.99.10.19/24" ];
      gateway = [ "10.99.10.1" ];
    };
    networks."40-wifi" = {
      matchConfig.Name = "wlan1";
      networkConfig = {
        LinkLocalAddressing = "no";
        IPv6AcceptRA = lib.mkForce false;
        Bridge = "br-home";
      };
      DHCP = "no";
    };
  };

  networking.nftables.firewall.zones.wlan.interfaces = [ "wlan1" ];
  networking.nftables.firewall.zones.home.interfaces = [ "mv-home" ];
  networking.nftables.firewall.rules.wifi-forward = {
    from = [ "wlan" ];
    to = [ "home" ];
    verdict = "accept";
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
        # settings.vlan_file = "${pkgs.writeText "hostaps.vlans" ''
        #   10 wifi-home br-home
        #   50 wifi-guest br-guest
        # ''}";
        authentication = {
          saePasswords = [
            {
              password = "ctiectie";
              # vlanid = 10;
            }
            # {
            #   password = "nrsgnrsg";
            #   vlanid = 50;
            # }
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
