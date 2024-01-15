{
  config,
  #lib,
  ...
}: {
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network.networks = {
    "01-lan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
    };
    #"01-wlan1" = {
    #  address = ["192.168.1.2/24"];
    #  matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.wlan01.mac;
    #  networkConfig = {
    #    IPv6PrivacyExtensions = "yes";
    #    MulticastDNS = true;
    #  };
    #};
  };
  #networking.nat = {
  #  enable = true;
  #  externalInterface = "lan01";
  #  internalInterfaces  = ["wlan01"];
  #};
  #networking.firewall.enable = lib.mkForce false;
  #hardware.wirelessRegulatoryDatabase = true;
  #services.hostapd = {
  #  enable = true;
  #  radios.wlan01 = {
  #    band = "2g";
  #    countryCode = "DE";
  #    channel = 8;
  #    networks.wlan01 = {
  #      ssid = "patricks ist der tolleeste";
  #      authentication = {
  #        saePasswordsFile = lib.writeText "supidupipasswort";
  #        enableRecommendedPairwiseCiphers = true;
  #      };
  #    };
  #  };
  #};
}
