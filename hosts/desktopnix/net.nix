{
  config,
  pkgs,
  ...
}:
{
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
    wireless.iwd = {
      enable = true;
    };
  };
  systemd.network.networks = {
    "01-lan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
      };
    };
    "01-wlan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.wlan01.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
      };
    };
    "01-wlan2" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.wlan02.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
      };
    };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [
    "lan01"
    "wlan01"
    "wlan02"
  ];
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  environment.persistence."/state".directories = [
    "/var/lib/iwd"
    "/etc/mullvad-vpn"
  ];
}
