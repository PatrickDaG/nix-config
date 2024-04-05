{
  config,
  lib,
  ...
}: {
  imports = [../fireflyIII.nix];

  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [80];
  };

  services.firefly-iii = {
    enable = true;
    virtualHost = "money.${config.secrets.secrets.global.domains.web}";
    settings = {
      APP_URL = "https://money.${config.secrets.secrets.global.domains.web}";
      TZ = "Europe/Berlin";
      TRUSTED_PROXIES = lib.trace "fix" "*";
      SITE_OWNER = "firefly-admin@${config.secrets.secrets.global.domains.mail_public}";
      APP_KEY = lib.trace "fix" "ctiectiectiectctiectiectiectieie";
    };
  };
}
