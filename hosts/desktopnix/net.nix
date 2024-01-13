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
  networking.extraHosts = ''
    192.168.178.2 lel.lol
    192.168.178.2 pw.lel.lol
    192.168.178.2 nc.lel.lol
    192.168.178.2 adguardhome.lel.lol
    192.168.178.2 git.lel.lol
  '';
}
