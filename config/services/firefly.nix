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
  ];
}
