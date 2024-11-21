{ config, lib, ... }:
{
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [ config.services.adguardhome.port ];
  };
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    host = "0.0.0.0";
    port = 3000;

    settings = {
      dns = {
        bind_hosts = [
          (lib.net.cidr.host config.secrets.secrets.global.net.ips.${config.node.name}
            config.secrets.secrets.global.net.privateSubnetv4
          )
          (lib.net.cidr.host config.secrets.secrets.global.net.ips.${config.node.name}
            config.secrets.secrets.global.net.privateSubnetv6
          )
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
        "||adguardhome.${config.secrets.secrets.global.domains.web}^$dnsrewrite=${lib.net.cidr.host config.secrets.secrets.global.net.ips.elisabeth config.secrets.secrets.global.net.privateSubnetv4}"
        "||nc.${config.secrets.secrets.global.domains.web}^$dnsrewrite=${lib.net.cidr.host config.secrets.secrets.global.net.ips.elisabeth config.secrets.secrets.global.net.privateSubnetv4}"
        "||immich.${config.secrets.secrets.global.domains.web}^$dnsrewrite=${lib.net.cidr.host config.secrets.secrets.global.net.ips.elisabeth config.secrets.secrets.global.net.privateSubnetv4}"
        "||smb.${config.secrets.secrets.global.domains.web}^$dnsrewrite=${lib.net.cidr.host config.secrets.secrets.global.net.ips.elisabeth-samba config.secrets.secrets.global.net.privateSubnetv4}"
        "||fritz.box^$dnsrewrite=${lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnetv4}"
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
