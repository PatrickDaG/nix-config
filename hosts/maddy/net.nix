{config, ...}: {
  networking.hostId = config.secrets.secrets.local.networking.hostId;
  networking.domain = config.secrets.secrets.global.domains.mail;

  boot.initrd.systemd.network = {
    enable = true;
    networks = {inherit (config.systemd.network.networks) "lan01";};
  };

  systemd.network.networks = {
    "lan01" = let
      icfg = config.secrets.secrets.local.networking.interfaces.lan01;
    in {
      address = [
        icfg.hostCidrv4
        icfg.hostCidrv6
      ];
      gateway = ["fe80::1"];
      routes = [
        {routeConfig = {Destination = "172.31.1.1";};}
        {
          routeConfig = {
            Gateway = "172.31.1.1";
            GatewayOnLink = true;
          };
        }
      ];
      matchConfig.MACAddress = icfg.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      linkConfig.RequiredForOnline = "routable";
    };
  };
  age.secrets.cloudflare_token_acme = {
    rekeyFile = ./secrets/cloudflare_api_token.age;
    mode = "440";
    group = "acme";
  };
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.secrets.secrets.global.devEmail;
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      reloadServices = ["nginx"];
      credentialFiles = {
        "CF_DNS_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
        "CF_ZONE_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
      };
    };
  };
  security.acme.certs.mail = {
    domain = config.secrets.secrets.global.domains.mail;
    extraDomainNames = ["*.${config.secrets.secrets.global.domains.mail}"];
  };
  users.groups.acme.members = ["maddy"];
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/acme";
      user = "acme";
      group = "acme";
      mode = "0755";
    }
  ];
}
