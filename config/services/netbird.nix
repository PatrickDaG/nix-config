{ config, lib, ... }:
{
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [
      80 # dashboard
      3000 # management
      8012 # signal
      33080 # relay
    ];
  };

  age.secrets.coturnPassword = {
    generator.script = "alnum";
    owner = "turnserver";
  };

  age.secrets.coturnSecret = {
    generator.script = "alnum";
    owner = "turnserver";
  };

  age.secrets.relaySecret = {
    generator.script = "alnum";
    owner = "turnserver";
  };

  age.secrets.dataEnc = {
    generator.script =
      { pkgs, ... }:
      ''
        ${lib.getExe pkgs.openssl} rand -base64 32
      '';
    group = "netbird";
  };

  networking.firewall.allowedUDPPorts = [ 3478 ]; # STUN/TURN server
  services.netbird = {
    server = {
      enable = true;
      domain = "netbird.${config.secrets.secrets.global.domains.web}";

      dashboard = {
        enableNginx = true;
        settings = {
          AUTH_AUTHORITY = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/netbird";
          # Fix Kanidm not supporting fragmented URIs
          AUTH_REDIRECT_URI = "/peers";
          AUTH_SILENT_REDIRECT_URI = "/add-peers";
        };
      };

      relay.authSecretFile = config.age.secrets.relaySecret.path;

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
          };
          HttpConfig = {
            # This is not possible
            # failed validating JWT token sent from peer y1ParZkbzVMQGeU/KMycYl75v90i2O6EwgO1YQZnSFs= with error rpc error: code = Internal desc = unable to fetch account with claims, err: user ID is empty
            #AuthUserIDClaim = "preferred_username";
            AuthAudience = "netbird";
          };

          DataStoreEncryptionKey._secret = config.age.secrets.dataEnc.path;
        };
      };
    };
  };
  systemd.services.netbird-management.serviceConfig = {
    Restart = "always";
    RestartSec = 60;
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/netbird-mgmt";
      mode = "440";
      user = "netbird";
    }
  ];
}
