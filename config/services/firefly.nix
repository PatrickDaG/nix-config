{
  config,
  nodes,
  ...
}: {
  i18n.supportedLocales = ["all"];
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [80];
  };

  age.secrets.appKey = {
    generator.script = _: ''
      echo "base64:$(head -c 32 /dev/urandom | base64)"
    '';
    owner = "firefly-iii";
  };

  services.firefly-iii = {
    enable = true;
    enableNginx = true;
    virtualHost = "money.${config.secrets.secrets.global.domains.web}";
    settings = {
      APP_URL = "https://money.${config.secrets.secrets.global.domains.web}";
      TZ = "Europe/Berlin";
      TRUSTED_PROXIES = nodes.elisabeth.config.wireguard.elisabeth.ipv4;
      SITE_OWNER = "firefly-admin@${config.secrets.secrets.global.domains.mail_public}";
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
  ];
}
