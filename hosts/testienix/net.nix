{ config, ... }:
{
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan01" ];
  systemd.network.networks = {
    "lan01" = {
      address = [ "192.168.178.32/24" ];
      gateway = [ "192.168.178.1" ];
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
    };
  };
}
