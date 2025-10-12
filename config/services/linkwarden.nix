{
  config,
  globals,
  nodes,
  ...
}:
{
  age.secrets.linkwarden-nextauth-secret = {
    rekeyFile = config.node.secretsDir + "/linkwarden-nextauth-secret.age";
    generator.script = "base64";
    mode = "440";
    group = "linkwarden";
  };

  # Mirror the original oauth2 secret
  age.secrets.linkwarden-oauth2-client-secret = {
    inherit (nodes.elisabeth-kanidm.config.age.secrets.oauth2-linkwarden) rekeyFile;
    mode = "440";
    group = "linkwarden";
  };

  globals.wireguard.proxy-sentinel.hosts.${config.node.name}.firewallRuleForNode.sentinel.allowedTCPPorts =
    [ 3000 ];
  globals.wireguard.proxy-home.hosts.${config.node.name}.firewallRuleForNode.ward-web-proxy.allowedTCPPorts =
    [ 3000 ];

  globals.services.linkwarden.domain = globals.services.linkwarden.domain;
  globals.monitoring.http.linkwarden = {
    url = "https://${globals.services.linkwarden.domain}";
    expectedBodyRegex = "<title>Linkwarden";
    network = "internet";
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/linkwarden";
      user = "linkwarden";
      group = "linkwarden";
      mode = "0750";
    }
  ];

  services.linkwarden = {
    enable = true;
    host = "0.0.0.0";
    port = 3003;
    database.createLocally = true;
    enableRegistration = false;

    secretFiles.NEXTAUTH_SECRET = config.age.secrets.linkwarden-nextauth-secret.path;
    secretFiles.AUTHENTIK_CLIENT_SECRET = config.age.secrets.linkwarden-oauth2-client-secret.path;

    # NOTE: Well yes - it does not support generic OIDC so we piggyback on the AUTHENTIK provider
    environment = rec {
      RE_ARCHIVE_LIMIT = "0";
      NEXTAUTH_URL = "https://${globals.services.linkwarden.domain}/api/v1/auth";
      NEXT_PUBLIC_CREDENTIALS_ENABLED = "false"; # disables username / pass authentication
      NEXT_PUBLIC_AUTHENTIK_ENABLED = "true";
      NEXT_PUBLIC_MAX_FILE_BUFFER = "100"; # in MB
      AUTHENTIK_ISSUER = "https://${globals.services.kanidm.domain}/oauth2/openid/${AUTHENTIK_CLIENT_ID}";
      AUTHENTIK_CLIENT_ID = "linkwarden";
      AUTHENTIK_CUSTOM_NAME = "Kanidm (SSO)";
    };
  };

  backups.storageBoxes.dusk = {
    subuser = "linkwarden";
    paths = [ "/var/lib/linkwarden" ];
    withPostgres = true;
  };
}
