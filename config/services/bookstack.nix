{
  config,
  pkgs,
  globals,
  nodes,
  ...
}:
{
  globals.services.bookstack.host = config.node.name;
  age.secrets.bookstack_app_password = {
    generator.script = _: ''
      echo "base64:$(head -c 32 /dev/urandom | base64)"
    '';
    inherit (config.services.bookstack) group;
    owner = config.services.bookstack.user;
    mode = "440";
  };
  age.secrets.openid-secret = {
    inherit (nodes.${globals.services.kanidm.host}.config.age.secrets.oauth2-bookstack) rekeyFile;
    mode = "440";
    inherit (config.services.bookstack) group;
  };
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 80 ];
  };
  services.bookstack = {
    enable = true;
    hostname = globals.services.bookstack.domain;
    nginx.listenAddresses = [
      "0.0.0.0"
      "[::]"
    ];
    settings = rec {
      APP_ENV = "production";
      APP_KEY_FILE = config.age.secrets.bookstack_app_password.path;
      DB_CONNECTION = "mysql";
      DB_HOST = "localhost";
      DB_DATABASE = "bookstack";
      DB_USERNAME = "bookstack";
      DB_SOCKET = "/run/mysqld/mysqld.sock";
      AUTH_METHOD = "oidc";
      AUTH_AUTO_INITIATE = false;

      # Set the display name to be shown on the login button.
      # (Login with <name>)
      OIDC_NAME = "Kandim";

      # Name of the claims(s) to use for the user's display name.
      # Can have multiple attributes listed, separated with a '|' in which
      # case those values will be joined with a space.
      # Example: OIDC_DISPLAY_NAME_CLAIMS=given_name|family_name
      OIDC_DISPLAY_NAME_CLAIMS = "name";

      # OAuth Client ID to access the identity provider
      OIDC_CLIENT_ID = "bookstack";

      # OAuth Client Secret to access the identity provider
      OIDC_CLIENT_SECRET_FILE = config.age.secrets.openid-secret.path;

      # Issuer URL
      # Must start with 'https://'
      OIDC_ISSUER = "https://${globals.services.kanidm.domain}/oauth2/openid/${OIDC_CLIENT_ID}";

      # The "end session" (RP-initiated logout) URL to call during BookStack logout.
      # By default this is false which disables RP-initiated logout.
      # Setting to "true" will enable logout if found as supported by auto-discovery.
      # Otherwise, this can be set as a specific URL endpoint.
      OIDC_END_SESSION_ENDPOINT = false;

      # Enable auto-discovery of endpoints and token keys.
      # As per the standard, expects the service to serve a
      # `<issuer>/.well-known/openid-configuration` endpoint.
      OIDC_ISSUER_DISCOVER = true;
    };
  };
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "bookstack" ];
    ensureUsers = [
      {
        name = "bookstack";
        ensurePermissions = {
          "bookstack.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
  environment.persistence."/persist".directories = [
    {
      inherit (config.services.bookstack) user group;
      directory = config.services.bookstack.dataDir;
      mode = "0750";
    }
  ];
}
