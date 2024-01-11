{config, ...}: {
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network.networks = {
    "01-lan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.lan1.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
    };
  };
}
