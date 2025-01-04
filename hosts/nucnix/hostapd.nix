{
  globals,
  pkgs,
  ...
}:
{
  hardware.firmware = with pkgs; [
    linux-firmware
    intel2200BGFirmware
  ];
  #boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.nftables.firewall.zones.wlan.interfaces = [ "wlan1" ];
  networking.nftables.firewall.zones.home.interfaces = [ "br-home" ];
  networking.nftables.firewall.rules.wifi-forward = {
    from = [ "wlan" ];
    to = [ "home" ];
    verdict = "accept";
  };
  services.hostapd = {
    enable = true;
    radios.wlan01 = {
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
      networks.wlan01 = {
        inherit (globals.hostapd) ssid;
        apIsolate = true;
        # not supporte by laptop :(
        # settings.ieee80211w = 0;
        settings.bridge = "br-home";
        settings.vlan_file = "${pkgs.writeText "hostaps.vlans" ''
          10 wifi-home br-home
          50 wifi-guest br-guest
        ''}";
        authentication = {
          saePasswords = [
            {
              password = "ctiectie";
              vlanid = 10;
            }
            {
              password = "nrsgnrsg";
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
