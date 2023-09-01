{config, ...}: {
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network.networks = {
    "01-lan1" = {
      address = ["192.168.178.30/24"];
      gateway = ["192.168.178.1"];
      matchConfig.MACAddress = config.secrets.secrets.local.networking.lan1.mac;
      dns = ["192.168.178.2"];
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
    };
  };
}
