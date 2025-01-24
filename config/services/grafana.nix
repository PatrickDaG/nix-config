{
  config,
  globals,
  nodes,
  ...
}:
{
  imports = [
    ./influxdb.nix
    ./loki.nix
  ];
  wireguard.services = {
    client.via = "nucnix";
    firewallRuleForNode.${globals.services.nginx.host}.allowedTCPPorts = [
      config.services.grafana.settings.server.http_port
    ];
  };

  age.secrets.grafana-secret-key = {
    generator.script = "alnum";
    mode = "440";
    group = "grafana";
  };

  age.secrets.grafana-loki-basic-auth-password = {
    generator.script = "alnum";
    mode = "440";
    group = "grafana";
  };

  age.secrets.loki-basic-auth-hashes.generator.dependencies = [
    config.age.secrets.grafana-loki-basic-auth-password
  ];

  age.secrets.grafana-influxdb-token-machines = {
    generator.script = "alnum";
    mode = "440";
    group = "grafana";
  };

  age.secrets.grafana-influxdb-token-home = {
    generator.script = "alnum";
    mode = "440";
    group = "grafana";
  };

  # Mirror the original oauth2 secret
  age.secrets.grafana-oauth2-client-secret = {
    inherit (nodes.${globals.services.kanidm.host}.config.age.secrets.oauth2-grafana) rekeyFile;
    mode = "440";
    group = "grafana";
  };

  environment.persistence."/persist".directories = [
    {
      directory = config.services.grafana.dataDir;
      user = "grafana";
      group = "grafana";
      mode = "0700";
    }
  ];

  services.grafana = {
    enable = true;
    settings = {
      analytics.reporting_enabled = false;
      users.allow_sign_up = false;

      server = rec {
        inherit (globals.services.grafana) domain;
        root_url = "https://${domain}";
        enforce_domain = true;
        enable_gzip = true;
        http_addr = "0.0.0.0";
        http_port = 3000;
      };

      security = {
        disable_initial_admin_creation = true;
        secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
        cookie_secure = true;
        disable_gravatar = true;
        hide_version = true;
      };

      auth.disable_login_form = true;
      "auth.generic_oauth" = {
        enabled = true;
        name = "Kanidm";
        icon = "signin";
        allow_sign_up = true;
        #auto_login = true;
        client_id = "grafana";
        client_secret = "$__file{${config.age.secrets.grafana-oauth2-client-secret.path}}";
        scopes = "openid email profile";
        login_attribute_path = "preferred_username";
        auth_url = "https://${globals.services.kanidm.domain}/ui/oauth2";
        token_url = "https://${globals.services.kanidm.domain}/oauth2/token";
        api_url = "https://${globals.services.kanidm.domain}/oauth2/openid/grafana/userinfo";
        use_pkce = true;
        # Allow mapping oauth2 roles to server admin
        allow_assign_grafana_admin = true;
        role_attribute_path = "contains(groups[*], 'server_admin') && 'GrafanaAdmin' || contains(groups[*], 'admin') && 'Admin' || contains(groups[*], 'editor') && 'Editor' || 'Viewer'";
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "InfluxDB (machines)";
          type = "influxdb";
          access = "proxy";
          url = "http://localhost:8086";
          orgId = 1;
          secureJsonData.token = "$__file{${config.age.secrets.grafana-influxdb-token-machines.path}}";
          jsonData.version = "Flux";
          jsonData.organization = "machines";
          jsonData.defaultBucket = "telegraf";
        }
        {
          name = "InfluxDB (home_assistant)";
          type = "influxdb";
          access = "proxy";
          url = "http://localhost:8086";
          orgId = 1;
          secureJsonData.token = "$__file{${config.age.secrets.grafana-influxdb-token-home.path}}";
          jsonData.version = "Flux";
          jsonData.organization = "home";
          jsonData.defaultBucket = "home_assistant";
        }
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
          orgId = 1;
          basicAuth = true;
          basicAuthUser = "${config.node.name}+grafana-loki-basic-auth-password";
          secureJsonData.basicAuthPassword = "$__file{${config.age.secrets.grafana-loki-basic-auth-password.path}}";
        }
      ];
    };
  };

  systemd.services.grafana.serviceConfig.RestartSec = "60"; # Retry every minute
}
