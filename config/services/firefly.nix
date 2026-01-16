{
  config,
  globals,
  ...
}:
{
  globals.services.firefly.host = config.node.name;
  i18n.supportedLocales = [ "all" ];
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 80 ];
  };
  globals.services.fireflypico.host = config.node.name;
  globals.services.firefly-data-importer.host = config.node.name;
  networking.hosts = {
    "127.0.0.1" = [ globals.services.firefly.domain ];
  };

  age.secrets.appKey = {
    generator.script = _: ''
      echo "base64:$(head -c 32 /dev/urandom | base64)"
    '';
    owner = "firefly-iii";
  };
  age.secrets.firefly-token = {
    owner = "firefly-iii-data-importer";
    mode = "440";
    rekeyFile = config.node.secretsDir + "/firefly-access-token.age";
  };
  age.secrets.nordigen-id = {
    owner = "firefly-iii-data-importer";
    mode = "440";
    rekeyFile = config.node.secretsDir + "/nordigen_id.age";
  };
  age.secrets.nordigen-key = {
    owner = "firefly-iii-data-importer";
    mode = "440";
    rekeyFile = config.node.secretsDir + "/nordigen_key.age";
  };

  services.firefly-iii = {
    enable = true;
    enableNginx = true;
    virtualHost = globals.services.firefly.domain;
    settings = {
      AUDIT_LOG_LEVEL = "emergency";
      APP_URL = "https://${globals.services.firefly.domain}";
      TZ = "Europe/Berlin";
      TRUSTED_PROXIES = globals.wireguard.services.hosts.nucnix-nginx.ipv4;
      SITE_OWNER = "firefly-admin@${globals.domains.mail_public}";
      APP_KEY_FILE = config.age.secrets.appKey.path;
      AUTHENTICATION_GUARD = "remote_user_guard";
      AUTHENTICATION_GUARD_HEADER = "X-User";
      AUTHENTICATION_GUARD_EMAIL = "X-Email";
    };
  };
  # To allow api access from local
  services.nginx.virtualHosts.${config.services.firefly-iii.virtualHost}.listenAddresses = [
    "127.0.0.1"
    "[::1]"
    "[::0]"
    "0.0.0.0"
  ];

  services.firefly-iii-data-importer = {
    enable = true;
    enableNginx = true;
    virtualHost = globals.services.firefly-data-importer.domain;
    settings = {
      TZ = "Europe/Berlin";
      FIREFLY_III_URL = "http://${globals.services.firefly.domain}";
      VANITY_URL = config.services.firefly-iii.settings.APP_URL;
      TRUSTED_PROXIES = globals.wireguard.services.hosts.nucnix-nginx.ipv4;
      EXPECT_SECURE_URL = false;
      FIREFLY_III_ACCESS_TOKEN_FILE = config.age.secrets.firefly-token.path;
      NORDIGEN_ID_FILE = config.age.secrets.nordigen-id.path;
      NORDIGEN_KEY_FILE = config.age.secrets.nordigen-key.path;
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = config.services.firefly-iii.dataDir;
      user = "firefly-iii";
    }
    {
      directory = "/var/lib/firefly-pico";
      user = "firefly-pico";
    }
    {
      directory = config.services.firefly-iii-data-importer.dataDir;
      user = "firefly-iii-data-importer";
    }
  ];

  age.secrets.appKeyPico = {
    generator.script = _: ''
      echo "base64:$(head -c 32 /dev/urandom | base64)"
    '';
    owner = "firefly-pico";
  };

  services.phpfpm.settings = {
    log_level = "notice";
  };

  # services.firefly-pico = {
  #   enable = true;
  #   enableNginx = true;
  #   virtualHost = globals.services.fireflypico.domain;
  #   settings = {
  #     APP_URL = "https://${globals.services.fireflypico.domain}";
  #     TZ = "Europe/Berlin";
  #     FIREFLY_URL = "http://${globals.services.firefly.domain}";
  #     APP_KEY_FILE = config.age.secrets.appKeyPico.path;
  #   };
  # };

}
