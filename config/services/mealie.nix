{
  config,
  nodes,
  globals,
  ...
}:
{
  # Mirror the original oauth2 secret, but prepend OIDC_CLIENT_SECRET=
  # so it can be used as an EnvironmentFile
  age.secrets.oauth2-client-secret = {
    generator.dependencies = [
      nodes.${globals.services.kanidm.host}.config.age.secrets.oauth2-mealie
    ];
    generator.script =
      {
        lib,
        decrypt,
        deps,
        ...
      }:
      ''
        echo -n "OIDC_CLIENT_SECRET="
        ${decrypt} ${lib.escapeShellArg (lib.head deps).file}
      '';
    mode = "440";
  };
  globals.services.mealie.host = config.node.name;
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ config.services.mealie.port ];
  };
  services.mealie = {
    enable = true;
    database.createLocally = true;
    port = 3002;
    settings = rec {
      BASE_URL = "https://${globals.services.mealie.domain}";
      TZ = config.time.timeZone;
      TOKEN_TIME = 87600; # 10 years session time - this is only internal so who cares
      ALLOW_SIGNUP = "false";
      OIDC_AUTH_ENABLED = "true";
      OIDC_SIGNUP_ENABLED = "true";
      OIDC_AUTO_REDIRECT = "true";
      OIDC_REMEMBER_ME = "true";
      ALLOW_PASSWORD_LOGIN = "false";

      OIDC_CLIENT_ID = "mealie";
      OIDC_USER_CLAIM = "preferred_username";
      OIDC_PROVIDER_NAME = "Kanidm";
      OIDC_CONFIGURATION_URL = "https://${globals.services.kanidm.domain}/oauth2/openid/${OIDC_CLIENT_ID}/.well-known/openid-configuration";
      OIDC_USER_GROUP = "mealie.access@${globals.services.kanidm.domain}";
      OIDC_ADMIN_GROUP = "mealie.admins@${globals.services.kanidm.domain}";
    };
    extraOptions = [
      "--forwarded-allow-ips=${globals.wireguard.services.hosts.nucnix-nginx.ipv4}"
    ];
    credentialsFile = config.age.secrets.oauth2-client-secret.path;
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/mealie";
      mode = "0700";
    }
  ];
}
