{
  config,
  globals,
  ...
}:
{
  globals.wireguard = {
    users.hosts.${config.node.name} = { };
    services.hosts.${config.node.name} = { };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [ "users" ];

  services.nginx = {
    enable = true;
    recommendedSetup = true;
    # Never listen on the house LAN or service WireGuard network.
    defaultListenAddresses = [
      globals.wireguard.users.hosts.${config.node.name}.ipv4
      "[${globals.wireguard.users.hosts.${config.node.name}.ipv6}]"
    ];

    upstreams = {
      homeassistant-nucnix = {
        servers."${
          globals.wireguard.services.hosts.${globals.services.homeassistant-nucnix.host}.ipv4
        }:3000" =
          { };
        extraConfig = ''
          zone homeassistant-nucnix 64k;
          keepalive 5;
        '';
      };
      esphome-nucnix = {
        servers."${globals.wireguard.services.hosts.${globals.services.esphome-nucnix.host}.ipv4}:3001" =
          { };
        extraConfig = ''
          zone esphome-nucnix 64k;
          keepalive 5;
        '';
      };
    };

    virtualHosts.${globals.services.homeassistant-nucnix.domain} = {
      forceSSL = true;
      useACMEHost = "web";
      locations."/" = {
        proxyPass = "http://homeassistant-nucnix";
        proxyWebsockets = true;
        X-Frame-Options = "SAMEORIGIN";
      };
      extraConfig = ''
        client_max_body_size 500M;
      '';
    };

    virtualHosts.${globals.services.esphome-nucnix.domain} = {
      forceSSL = true;
      useACMEHost = "web";
      locations = {
        "/" = {
          proxyPass = "http://esphome-nucnix";
          proxyWebsockets = true;
          X-Frame-Options = "SAMEORIGIN";
        };
      };
      extraConfig = ''
        client_max_body_size 500M;
      '';
    };
  };

  age.secrets.cloudflare_token_acme = {
    rekeyFile = config.node.secretsDir + "/cloudflare_api_token.age";
    mode = "440";
    group = "acme";
  };
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = globals.accounts.email."1".address;
      dnsProvider = "cloudflare";
      # Bypass system DNS caches when checking short-lived ACME challenge records.
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      reloadServices = [ "nginx" ];
      credentialFiles = {
        "CF_DNS_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
        "CF_ZONE_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
      };
    };
    certs.web = {
      domain = globals.domains.web;
      extraDomainNames = [ "*.${globals.domains.web}" ];
    };
  };
  users.groups.acme.members = [ "nginx" ];
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/acme";
      user = "acme";
      group = "acme";
      mode = "0755";
    }
  ];
}
