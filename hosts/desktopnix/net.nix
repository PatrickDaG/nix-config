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
  services.firezone.gui-client = {
    enable = true;
    inherit (config.node) name;
    allowedUsers = [ "patrick" ];
  };
}
