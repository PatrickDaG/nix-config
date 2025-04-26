{
  config,
  globals,
  ...
}:
{
  i18n.supportedLocales = [ "all" ];
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 80 ];
  };
  globals.services.fireflypico.host = config.node.name;

  age.secrets.appKey = {
    generator.script = _: ''
      echo "base64:$(head -c 32 /dev/urandom | base64)"
    '';
    owner = "firefly-iii";
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

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/firefly-iii";
      user = "firefly-iii";
    }
    {
      directory = "/var/lib/firefly-pico";
      user = "firefly-pico";
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

  services.firefly-pico = {
    enable = true;
    enableNginx = true;
    virtualHost = globals.services.fireflypico.domain;
    settings = {
      LOG_CHANNEL = "syslog";
      APP_URL = "https://${globals.services.fireflypico.domain}";
      TZ = "Europe/Berlin";
      FIREFLY_URL = config.services.firefly-iii.settings.APP_URL;
      TRUSTED_PROXIES = globals.wireguard.services.hosts.nucnix-nginx.ipv4;
      SITE_OWNER = "firefly-admin@${globals.domains.mail_public}";
      APP_KEY_FILE = config.age.secrets.appKeyPico.path;
    };
  };

}
