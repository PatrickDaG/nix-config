{config, ...}: {
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network.networks = {
    "01-lan1" = {
      address = ["192.168.178.32/24"];
      gateway = ["192.168.178.1"];
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
      dns = ["192.168.178.2"];
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
    };
  };

  boot.initrd.systemd.network = {
    enable = true;
    networks = {inherit (config.systemd.network.networks) "01-lan1";};
  };
}
