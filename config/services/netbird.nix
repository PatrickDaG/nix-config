{
  config,
  lib,
  ...
}: {
  disabledModules = ["services/networking/netbird/server.nix"];
  imports = [../../modules/netbird/server.nix];
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
    owner = "turnserver";
  };

  age.secrets.dataEnc = {
    generator.script = {pkgs, ...}: ''
      ${lib.getExe pkgs.openssl} rand -base64 32
    '';
    group = "netbird";
  };

  networking.firewall.allowedTCPPorts = [80 3000 3001];
  networking.firewall.allowedUDPPorts = [3478];
  services.netbird = {
    server = {
      enable = true;
      domain = "netbird.${config.secrets.secrets.global.domains.web}";

      dashboard = {
        enableNginx = true;
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
          };
          DataStoreEncryptionKey._secret = config.age.secrets.dataEnc.path;
        };
      };
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/netbird-mgmt";
      mode = "440";
      user = "netbird";
    }
  ];
}
