{
  config,
  lib,
  ...
}: {
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network.networks = {
    "lan01" = {
      address = [(lib.net.cidr.host config.secrets.secrets.global.net.ips.${config.node.name} config.secrets.secrets.global.net.privateSubnet)];
      gateway = [(lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnet)];
      #matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
      matchConfig.Name = "lan";
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
    };
  };
  boot.initrd.systemd.network = {
    enable = true;
    networks = {
      # redo the network cause the livesystem has macvlans
      "lan01" = {
        address = [(lib.net.cidr.host config.secrets.secrets.global.net.ips.${config.node.name} config.secrets.secrets.global.net.privateSubnet)];
        gateway = [(lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnet)];
        matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
        networkConfig = {
          IPv6PrivacyExtensions = "yes";
          MulticastDNS = true;
        };
      };
    };
  };
  # To be able to ping containers from the host, it is necessary
  # to create a macvlan on the host on the VLAN 1 network.
  networking.macvlans.lan = {
    interface = "lan01";
    mode = "bridge";
  };
}
