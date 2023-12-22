{config, ...}: {
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network.networks = {
    "lan01" = {
      address = ["192.168.178.32/24"];
      gateway = ["192.168.178.1"];
      #matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
      matchConfig.Name = "mv-lan01";
      dns = ["192.168.178.2"];
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
    };
  };
  # To be able to ping containers from the host, it is necessary
  # to create a macvlan on the host on the VLAN 1 network.
  networking.macvlans.mv-lan01 = {
    interface = "lan01";
    mode = "bridge";
  };

  boot.initrd.systemd.network = {
    enable = true;
    networks = {
      # redo the network cause the livesystem has macvlans
      "lan01" = {
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
  };
}
