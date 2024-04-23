{
  config,
  lib,
  ...
}: {
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [80 3000 3001];
  };

  age.secrets.coturnPassword = {
    generator.script = "alnum";
    group = "netbird";
  };

  age.secrets.coturnSecret = {
    generator.script = "alnum";
    group = "netbird";
  };

  age.secrets.dataEnc = {
    generator.script = "alnum";
    group = "netbird";
  };

  networking.firewall.allowedTCPPorts = [80 3000 3001];
  networking.firewall.allowedUDPPorts = [3478];
  services.netbird = {
    server = {
      enable = true;
      domain = "netbird.${config.secrets.secrets.global.domains.web}";

      dashboard = {
        enableNginx = lib.mkForce true;
        settings = {
          AUTH_AUTHORITY = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/netbird";
        };
      };

      coturn = {
        enable = true;
        passwordFile = config.age.secrets.coturnPassword.path;
      };

      management = {
        port = 3000;
        dnsDomain = "internal.${config.secrets.secrets.global.domains.web}";
        singleAccountModeDomain = "netbird.patrick";
        oidcConfigEndpoint = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/netbird/.well-known/openid-configuration";
        settings = {
          TURNConfig = {
            Secret._secret = config.age.secrets.coturnSecret.path;
            # TODO I think this is broken
            Turns = [
              {
                Password._secret = config.age.secrets.coturnPassword.path;
              }
            ];
          };
          DataStoreEncryptionKey._secret = config.age.secrets.dataEnc.path;
        };
      };
    };
  };
  security.acme.certs = lib.mkForce {};
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/netbird-mgmt";
      mode = "440";
      user = "netbird";
    }
  ];
}
