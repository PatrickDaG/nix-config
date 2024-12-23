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
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan-services" ];
  hardware.wirelessRegulatoryDatabase = true;
  # systemd.network = {
  #   netdevs."40-wifi-home" = {
  #     netdevConfig = {
  #       Name = "br-home";
  #       Kind = "bridge";
  #     };
  #   };
  #   networks."10-home-bridge" = {
  #     networkConfig.LinkLocalAddressing = "no";
  #     matchConfig.Name = "lan-home";
  #     DHCP = "no";
  #     extraConfig = ''
  #       [Network]
  #       Bridge=br-home
  #     '';
  #   };
  #   networks."10-home-" = {
  #     matchConfig.Name = "br-home";
  #     DHCP = "yes";
  #   };
  # };

  networking.nftables.firewall.zones.wlan.interfaces = [ "wlan1" ];
  networking.nftables.firewall.zones.home.interfaces = [ "lan-home" ];
  networking.nftables.firewall.rules.wifi-forward = {
    from = [ "wlan" ];
    to = [ "lan-home" ];
    verdict = "accept";
  };
  systemd.network.networks."40-wifi" = {
    matchConfig.Name = "lan-home";
    address = [
      (lib.net.cidr.hostCidr (globals.services.hostapd.ip + 1) globals.net.vlans.home.cidrv4)
      (lib.net.cidr.hostCidr (globals.services.hostapd.ip + 1) globals.net.vlans.home.cidrv6)
    ];
    gateway = [
      (lib.net.cidr.host 1 globals.net.vlans.home.cidrv4)
      (lib.net.cidr.host 1 globals.net.vlans.home.cidrv6)
    ];

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
