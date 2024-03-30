{config, ...}: {
  imports = [
    ../netbird-server.nix
    ../netbird-dashboard.nix
  ];
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [80 3000 3001];
  };

  networking.firewall.allowedTCPPorts = [80 3000 3001];
  networking.firewall.allowedUDPPorts = [3478];
  services.netbird-dashboard = {
    enable = true;
    enableNginx = true;
    domain = "netbird.${config.secrets.secrets.global.domains.web}";
    settings = {
      AUTH_AUTHORITY = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/netbird";
    };
  };
  services.netbird-server = {
    enableCoturn = true;
    enable = true;
    domain = "netbird.${config.secrets.secrets.global.domains.web}";
    oidcConfigEndpoint = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/netbird/.well-known/openid-configuration";
    singleAccountModeDomain = "netbird.patrick";
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/netbird-mgmt";
      mode = "440";
      user = "netbird";
    }
  ];
}
