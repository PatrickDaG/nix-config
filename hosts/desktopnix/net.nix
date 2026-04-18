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
      dhcpV4Config = {
        UseDNS = false;
        RouteMetric = 10;
      };
      ipv6AcceptRAConfig.UseDNS = false;
      dhcpV6Config = {
        UseDNS = false;
        RouteMetric = 10;
      };
    };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [
    "lan01"
  ];
  # services.mullvad-vpn = {
  #   enable = true;
  #   package = pkgs.mullvad-vpn;
  # };
  environment.persistence."/state".directories = [
    "/var/lib/iwd"
    #"/etc/mullvad-vpn"
  ];
  globals.wireguard.users.hosts.${config.node.name} = { };
}
