{
  globals,
  config,
  pkgs,
  lib,
  ...
}:
{
  hardware.firmware = with pkgs; [
    linux-firmware
    intel2200BGFirmware
  ];
  #boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  age.secrets = {
    homeWlan = {
      generator.script = "alnum";
    };
    guestWlan = {
      generator.script = "alnum";
    };
    iotWlan = {
      generator.script = "alnum";
    };
  };
  systemd.services.hostapd.stopIfChanged = false;
  systemd.services.hostapd.restartIfChanged = false;
  systemd.services.hostapd.reloadTriggers = lib.mkForce [ ];

  # networking.nftables.firewall.zones.wlan.interfaces = [ "wlan1" ];
  # networking.nftables.firewall.zones.home.interfaces = [ "br-home" ];
  # networking.nftables.firewall.rules.wifi-forward = {
  #   from = [ "wlan" ];
  #   to = [ "home" ];
  #   verdict = "accept";
  # };
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
        settings.vlan_file = "${pkgs.writeText "hostaps.vlans" ''
          10 wifi-home br-home
          40 wifi-iot br-iot
          50 wifi-guests br-guests
        ''}";
        authentication = {
          saePasswords = [
            {
              passwordFile = config.age.secrets.homeWlan.path;
              vlanid = 10;
            }
            {
              passwordFile = config.age.secrets.iotWlan.path;
              vlanid = 40;
            }
            {
              passwordFile = config.age.secrets.guestWlan.path;
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
