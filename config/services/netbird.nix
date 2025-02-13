{
  config,
  lib,
  globals,
  ...
}:
{
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [
      80 # dashboard
      3000 # management
      8012 # signal
      33080 # relay
    ];
  };
  networking.nftables.chains.forward.from-netbird = {
    after = [ "conntrack" ];
    rules = [
      "iifname nb-main oifname { lan-home, lan-services } accept"
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

  networking.firewall.allowedUDPPorts = [
    3478
  ]; # STUN/TURN server
  services.netbird = {
    clients.main = {
      port = 51820;
      environment = {
        NB_MANAGEMENT_URL = "https://${globals.services.netbird.domain}";
        NB_ADMIN_URL = "https://${globals.services.netbird.domain}";
        NB_HOSTNAME = "home";
      };
    };

    server = {
      enable = true;
      inherit (globals.services.netbird) domain;

      dashboard = {
        enableNginx = true;
        settings = {
          AUTH_AUTHORITY = "https://${globals.services.kanidm.domain}/oauth2/openid/netbird";
          # Fix Kanidm not supporting fragmented URIs
          AUTH_REDIRECT_URI = "/peers";
          AUTH_SILENT_REDIRECT_URI = "/add-peers";
        };
      };

      relay = {
        authSecretFile = config.age.secrets.relaySecret.path;
        settings.NB_EXPOSED_ADDRESS = "rels://${globals.services.netbird.domain}:443";
      };

      coturn = {
        enable = true;
        passwordFile = config.age.secrets.coturnPassword.path;
      };

      management = {
        port = 3000;
        # DNS server should do the lookup this is not used
        dnsDomain = "internal.invalid";
        singleAccountModeDomain = "netbird.patrick";
        oidcConfigEndpoint = "https://${globals.services.kanidm.domain}/oauth2/openid/netbird/.well-known/openid-configuration";
        settings = {
          TURNConfig = {
            Secret._secret = config.age.secrets.coturnSecret.path;
          };
          Signal.URI = "${globals.services.netbird.domain}:443";
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
    {
      directory = "/var/lib/netbird-main";
      mode = "440";
      user = "netbird-main";
    }
  ];
}
