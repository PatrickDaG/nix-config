{ config, ... }:

{

  hardware.wirelessRegulatoryDatabase = true;

  services.hostapd = {
    enable = true;
    radios.wlan1 = {
      band = "2g";
      countryCode = "DE";
      # wifi4.capabilities = [
      #   "LDPC"
      #   "HT40+"
      #   "HT40-"
      #   "GF"
      #   "SHORT-GI-20"
      #   "SHORT-GI-40"
      #   "TX-STBC"
      #   "RX-STBC1"
      # ];
      wifi6.enable = true;
      wifi7.enable = true;
      networks.wlan1 = {
        inherit (config.secrets.secrets.global.hostapd) ssid;
        apIsolate = true;
        authentication = {
          saePasswords = [
            {
              password = "lol";
              vlanid = 10;
            }
          ];
          enableRecommendedPairwiseCiphers = true;
        };
        bssid = "02:c0:ca:b1:4f:9f";
      };
    };
  };
}
