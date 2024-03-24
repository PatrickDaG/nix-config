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
      AUTH_CLIENT_ID = "netbird";
    };
  };
  services.netbird-server = {
    enable = true;
    domain = "netbird.${config.secrets.secrets.global.domains.web}";
    # TODO remove
    oidcConfigEndpoint = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/netbird/.well-known/openid-configuration";
    singleAccountModeDomain = "netbird.patrick";
    # todo disabel metrics
    settings = {
      HttpConfig = {
        #AuthIssuer = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/netbird";
        #AuthKeysLocation = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/netbird/public_key.jwk";
        AuthAudience = "netbird";
      };
      # Seems to be only useful for idp that netbird supports
      IdpManagerConfig.ClientConfig = {
        #Issuer = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/netbird";
        #TokenEndpoint = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/token";
      };
      #DeviceAuthorizationFlow = {
      #  Provider = "none";
      #  ProviderConfig = {
      #    AuthorizationEndpoint = "https://auth.${config.secrets.secrets.global.domains.web}/ui/oauth2/";
      #    ClientID = "netbird";
      #    #ClientSecret = "";
      #    TokenEndpoint = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/token";
      #    #RedirectURLs = ["http://localhost:53000"];
      #  };
      #};
      PKCEAuthorizationFlow.ProviderConfig = {
        #AuthorizationEndpoint = "https://auth.${config.secrets.secrets.global.domains.web}/ui/oauth2/";
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
  services.nginx.recommendedSetup = true;
  services.coturn = {
    enable = true;

    realm = "netbird.${config.secrets.secrets.global.domains.web}";
    lt-cred-mech = true;
    no-cli = true;

    extraConfig = ''
      fingerprint

      user=turn:netbird
      no-software-attribute
      external-ip=87.170.9.213
    '';
  };
}
