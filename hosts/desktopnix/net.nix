{
  config,
  pkgs,
  ...
}:
{
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
    "01-wlan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.wlan01.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
    };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan01" ];
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  environment.persistence."/state".directories = [
    "/etc/mullvad-vpn"
    {
      directory = "/var/lib/netbird-main";
      user = "netbird-main";
    }
  ];
  services.netbird = {
    clients.main = {
      port = 51820;
      environment = {
        NB_MANAGEMENT_URL = "https://netbird.${config.secrets.secrets.global.domains.web}";
        NB_ADMIN_URL = "https://netbird.${config.secrets.secrets.global.domains.web}";
        NB_HOSTNAME = "desktopnix";
      };
    };
  };
  users.users."patrick".extraGroups = [ "netbird-main" ];
}
