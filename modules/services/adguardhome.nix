{
  config,
  lib,
  ...
}: {
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true; # opens webinterface firewall
    settings = {
      bind_port = 3000;
      bind_host = "0.0.0.0";
      dns = {
        bind_hosts = [(lib.net.cidr.host config.secrets.secrets.global.net.ips.${config.node.name} config.secrets.secrets.global.net.privateSubnet)];
        anonymize_client_ip = false;
        upstream_dns = [
          "1.0.0.1"
          "2606:4700:4700::1111"
          "8.8.8.8"
          "2001:4860:4860::8844"
        ];
        bootstrap_dns = [
          "1.0.0.1"
          "2606:4700:4700::1111"
          "8.8.8.8"
          "2001:4860:4860::8844"
        ];
      };
      user_rules = [
        "||adguardhome.${config.secrets.secrets.global.domains.web}^$dnsrewrite=${lib.net.cidr.host config.secrets.secrets.global.net.ips.elisabeth config.secrets.secrets.global.net.privateSubnet}"
        "||nc.${config.secrets.secrets.global.domains.web}^$dnsrewrite=${lib.net.cidr.host config.secrets.secrets.global.net.ips.elisabeth config.secrets.secrets.global.net.privateSubnet}"
        "||fritz.box^$dnsrewrite=${lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnet}"
      ];
      dhcp.enabled = false;
      ratelimit = 60;
      users = [
        {
          name = "patrick";
          password = "$2y$10$cmdb7U/qbtUvrcFeKQvr6.BPrm/UwCiP.gBW2jG0Aq24hnzd2co4m";
        }
      ];
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
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/AdGuardHome";
      mode = "0700";
    }
  ];
}
