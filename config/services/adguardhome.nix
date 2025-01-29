{
  config,
  lib,
  globals,
  ...
}:
{
  wireguard.services = {
    client.via = "nucnix";
    firewallRuleForNode.${globals.services.nginx.host}.allowedTCPPorts = [
      config.services.adguardhome.port
    ];
    firewallRuleForNode.${globals.services.homeassistant.host}.allowedTCPPorts = [
      config.services.adguardhome.port
    ];
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
        "@@||${globals.services.vaultwarden.domain}^$dnsrewrite"
        "||fritz.box^$dnsrewrite=${lib.net.cidr.host 1 "10.99.2.0/24"}"
      ];
      dhcp.enabled = false;
      ratelimit = 60;
      querylog = {
        size_memory = 5;
        ignored = [ "." ];
        #dir_path = "/run";
      };
      statistics.ignored = [ "." ];
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
      user = "adguardhome";
      group = "adguardhome";
      directory = "/var/lib/AdGuardHome";
      mode = "0750";
    }
  ];
  globals.monitoring.dns.adguardhome = {
    server = lib.net.cidr.host globals.services.adguardhome.ip globals.net.vlans.services.cidrv4;
    domain = ".";
    network = "home";
  };
  systemd.services.telegraf.serviceConfig.SupplementaryGroups = [ "adguardhome" ];
  users.groups.adguardhome = { };
  users.users.adguardhome.group = "adguardhome";
  systemd.services.adguardhome.serviceConfig = {
    UMask = "027";
    DynamicUser = lib.mkForce false;
    User = "adguardhome";
    Group = "adguardhome";
  };
  services.telegraf.extraConfig = {
    agent.debug = true;
    inputs.tail = {
      files = [ "/var/lib/AdGuardHome/data/querylog.json" ];
      data_format = "xpath_json";
      xpath_allow_empty_selection = true;
      xpath_native_types = true;
      xpath = [
        {
          timestamp = "/T";
          timestamp_format = "2006-01-02T15:04:05.999999999Z07:00";
          field_selection = "Elapsed";
          tag_selection = lib.concatStringsSep "|" [
            "IP"
            "QH"
            "QT"
            "QC"
            "CP"
            "Upstream"
            "Result/Reason"
          ];
        }
      ];
    };

    processors.regex = [
      {
        tags = [
          {
            key = "IP";
            result_key = "IP_24";
            pattern = "^(\\d+)\\.(\\d+)\\.(\\d+)\\.(\\d+)$";
            replacement = "$\${1}.$\${2}.$\${3}.x";
          }
          {
            key = "QH";
            result_key = "TLD";
            pattern = "^.*?(?P<tld>[^.]+\\.[^.]+)$";
            replacement = "$\${tld}";
          }
        ];
      }
    ];
  };
}
