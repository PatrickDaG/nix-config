{
  config,
  lib,
  globals,
  ...
}:
{
  wireguard.services = {
    client.via = "nucnix";
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ config.services.adguardhome.port ];
  };
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    host = "0.0.0.0";
    port = 3000;

    settings = {
      dns = {
        bind_hosts = [
          (lib.net.cidr.host globals.services.adguardhome.ip globals.net.vlans.services.cidrv4)
          (lib.net.cidr.host globals.services.adguardhome.ip globals.net.vlans.services.cidrv6)
        ];
        anonymize_client_ip = false;
        upstream_dns = [
          "https://dns.google/dns-query"
          "https://dns.quad9.net/dns-query"
          "https://dns.cloudflare.com/dns-query"
          "https://doh.mullvad.net/dns-query"
        ];
        bootstrap_dns = [
          "1.0.0.1"
          "2606:4700:4700::1111"
          "8.8.8.8"
          "2001:4860:4860::8844"
        ];
      };
      user_rules = [
        "||homematic.internal^$dnsrewrite=${lib.net.cidr.host 30 globals.net.vlans.devices.cidrv4}"
        "||testberry.internal^$dnsrewrite=${lib.net.cidr.host 31 globals.net.vlans.devices.cidrv4}"
        "||smb.internal^$dnsrewrite=${lib.net.cidr.host globals.services.samba.ip globals.net.vlans.home.cidrv4}"
        "||${globals.domains.web}^$dnsrewrite=${lib.net.cidr.host 1 globals.net.vlans.services.cidrv4}"
        "||fritz.box^$dnsrewrite=${lib.net.cidr.host 1 "10.99.2.0/24"}"
      ];
      dhcp.enabled = false;
      ratelimit = 60;
      filters = [
        {
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
          enabled = true;
        }
        {
          name = "AdaAway Default Blocklist";
          url = "https://adaway.org/hosts.txt";
          enabled = true;
        }
        {
          name = "OISD (Big)";
          url = "https://big.oisd.nl";
          enabled = true;
        }
      ];
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/AdGuardHome";
      mode = "0700";
    }
  ];
}
