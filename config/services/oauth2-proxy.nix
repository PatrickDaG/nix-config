{
  config,
  nodes,
  globals,
  ...
}:
{
  wireguard.services = {
    client.via = "nucnix";
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 3000 ];
  };

  age.secrets.oauth2-cookie-secret = {
    rekeyFile = config.node.secretsDir + "/cookie-secret.age";
    mode = "440";
    group = "oauth2-proxy";
  };

  services.oauth2-proxy = {
    enable = true;
    cookie.domain = ".${globals.domains.web}";
    cookie.secure = true;
    cookie.expire = "900m";
    cookie.secret = null;

    clientSecret = null;

    reverseProxy = true;
    httpAddress = "0.0.0.0:3000";
    redirectURL = "https://oauth2.${globals.domains.web}/oauth2/callback";
    setXauthrequest = true;
    extraConfig = {
      code-challenge-method = "S256";
      whitelist-domain = ".${globals.domains.web}";
      set-authorization-header = true;
      pass-access-token = true;
      skip-jwt-bearer-tokens = true;
      upstream = "static://202";

      oidc-issuer-url = "https://auth.${globals.domains.web}/oauth2/openid/oauth2-proxy";
      provider-display-name = "Kanidm";
      #client-secret-file = config.age.secrets.oauth2-client-secret.path;
    };

    provider = "oidc";
    scope = "openid email";
    loginURL = "https://auth.${globals.domains.web}/ui/oauth2";
    redeemURL = "https://auth.${globals.domains.web}/oauth2/token";
    validateURL = "https://auth.${globals.domains.web}/oauth2/openid/oauth2-proxy/userinfo";
    clientID = "oauth2-proxy";
    email.domains = [ "*" ];
  };

  systemd.services.oauth2-proxy.serviceConfig = {
    RuntimeDirectory = "oauth2-proxy";
    RuntimeDirectoryMode = "0750";
    UMask = "007"; # TODO remove once https://github.com/oauth2-proxy/oauth2-proxy/issues/2141 is fixed
    RestartSec = "60"; # Retry every minute
  };

  systemd.services.oauth2-proxy.serviceConfig.EnvironmentFile = [
    config.age.secrets.oauth2-cookie-secret.path
    config.age.secrets.oauth2-client-secret-env.path
  ];
  # Mirror the original oauth2 secret
  age.secrets.oauth2-client-secret = {
    inherit (nodes.elisabeth-kanidm.config.age.secrets.oauth2-proxy) rekeyFile;
    mode = "440";
    group = "oauth2-proxy";
  };
  # Mirror the original oauth2 secret, but prepend OAUTH2_PROXY_CLIENT_SECRET=
  # so it can be used as an EnvironmentFile
  # Using the normal secret file option does not work as
  # it includes the newline terminating the file which
  # makes kanidm reject the secret
  age.secrets.oauth2-client-secret-env = {
    generator.dependencies = [ nodes.elisabeth-kanidm.config.age.secrets.oauth2-proxy ];
    generator.script =
      {
        lib,
        decrypt,
        deps,
        ...
      }:
      ''
        echo -n "OAUTH2_PROXY_CLIENT_SECRET="
        ${decrypt} ${lib.escapeShellArg (lib.head deps).file}
      '';
    mode = "440";
    group = "oauth2-proxy";
  };
}
