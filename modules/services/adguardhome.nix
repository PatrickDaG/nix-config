{config, ...}: {
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true; # opens webinterface firewall
    settings = {
      bind_port = 3000;
      bind_host = "0.0.0.0";
      dns = {
        bind_hosts = ["TODO"];
        anonymize_client_ip = true;
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
      user_rules = ''
        ||${config.secrets.secrets.global.domains.web}^$dnsrewrite=TODO
      '';
      dhcp.enabled = false;
      ratelimit = 60;
      users = [
        {
          name = "patrick";
          password = "$2b$05$Dapc2LWUfebNOgIeBcaf2OVhW7uKmthmp9Ptykn96Iw1UE5pt2U72";
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
