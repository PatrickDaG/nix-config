{ config, pkgs, ... }:
let
  kanidmdomain = "auth.${config.secrets.secrets.global.domains.web}";
in
{
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [ 3000 ];
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/kanidm";
      user = "kanidm";
      group = "kanidm";
      mode = "0700";
    }
  ];
  age.secrets = {
    kanidm-cert = {
      rekeyFile = config.node.secretsDir + "/cert.age";
      group = "kanidm";
      mode = "440";
    };
    kanidm-key = {
      rekeyFile = config.node.secretsDir + "/key.age";
      group = "kanidm";
      mode = "440";
    };
    oauth2-nextcloud = {
      generator.script = "alnum";
      mode = "440";
      group = "kanidm";
    };
    oauth2-immich = {
      generator.script = "alnum";
      mode = "440";
      group = "kanidm";
    };
    oauth2-paperless = {
      generator.script = "alnum";
      mode = "440";
      group = "kanidm";
    };
    oauth2-proxy = {
      generator.script = "alnum";
      mode = "440";
      group = "kanidm";
    };
    oauth2-forgejo = {
      generator.script = "alnum";
      mode = "440";
      group = "kanidm";
    };
  };
  services.kanidm = {
    package = pkgs.kanidm.withSecretProvisioning;
    enableServer = true;
    serverSettings = {
      domain = kanidmdomain;
      origin = "https://${kanidmdomain}";
      tls_chain = config.age.secrets.kanidm-cert.path;
      tls_key = config.age.secrets.kanidm-key.path;
      bindaddress = "0.0.0.0:3000";
      trust_x_forward_for = true;
    };
    enableClient = true;
    clientSettings = {
      uri = config.services.kanidm.serverSettings.origin;
      verify_ca = true;
      verify_hostnames = true;
    };
    provision = {
      enable = true;

      inherit (config.secrets.secrets.local.kanidm) persons;

      groups."paperless.access" = {
        members = [ "paperless.admins" ];
      };
      # currently not usable
      groups."paperless.admins" = {
        members = [ "administrator" ];
      };
      systems.oauth2.paperless = {
        displayName = "paperless";
        originUrl = "https://ppl.${config.secrets.secrets.global.domains.web}/accounts/oidc/kanidm/login/callback/";
        originLanding = "https://ppl.${config.secrets.secrets.global.domains.web}/";
        basicSecretFile = config.age.secrets.oauth2-paperless.path;
        scopeMaps."paperless.access" = [
          "openid"
          "email"
          "profile"
        ];
        preferShortUsername = true;
      };

      groups."nextcloud.access" = {
        members = [ "nextcloud.admins" ];
      };
      # currently not usable
      groups."nextcloud.admins" = {
        members = [ "administrator" ];
      };
      systems.oauth2.nextcloud = {
        displayName = "nextcloud";
        originUrl = "https://nc.${config.secrets.secrets.global.domains.web}/";
        originLanding = "https://nc.${config.secrets.secrets.global.domains.web}/";
        basicSecretFile = config.age.secrets.oauth2-nextcloud.path;
        allowInsecureClientDisablePkce = true;
        scopeMaps."nextcloud.access" = [
          "openid"
          "email"
          "profile"
        ];
        preferShortUsername = true;
      };

      groups."immich.access" = {
        members = [ "immich.admins" ];
      };
      # currently not usable
      groups."immich.admins" = {
        members = [ "administrator" ];
      };
      systems.oauth2.immich = {
        displayName = "Immich";
        originUrl = "https://immich.${config.secrets.secrets.global.domains.web}/auth/login";
        originLanding = "https://immich.${config.secrets.secrets.global.domains.web}/";
        basicSecretFile = config.age.secrets.oauth2-immich.path;
        allowInsecureClientDisablePkce = true;
        enableLegacyCrypto = true;
        scopeMaps."immich.access" = [
          "openid"
          "email"
          "profile"
        ];
        preferShortUsername = true;
      };

      groups."rss.access" = { };
      groups."firefly.access" = { };
      groups."ollama.access" = { };
      groups."adguardhome.access" = { };
      groups."octoprint.access" = { };
      groups."invidious.access" = { };

      systems.oauth2.oauth2-proxy = {
        displayName = "Oauth2-Proxy";
        originUrl = "https://oauth2.${config.secrets.secrets.global.domains.web}/oauth2/callback";
        originLanding = "https://oauth2.${config.secrets.secrets.global.domains.web}/";
        basicSecretFile = config.age.secrets.oauth2-proxy.path;
        scopeMaps."adguardhome.access" = [
          "openid"
          "email"
          "profile"
        ];
        scopeMaps."rss.access" = [
          "openid"
          "email"
          "profile"
        ];
        scopeMaps."firefly.access" = [
          "openid"
          "email"
          "profile"
        ];
        scopeMaps."ollama.access" = [
          "openid"
          "email"
          "profile"
        ];
        scopeMaps."octoprint.access" = [
          "openid"
          "email"
          "profile"
        ];
        scopeMaps."invidious.access" = [
          "openid"
          "email"
          "profile"
        ];
        preferShortUsername = true;
        claimMaps.groups = {
          joinType = "array";
          valuesByGroup."adguardhome.access" = [ "adguardhome_access" ];
          valuesByGroup."rss.access" = [ "ttrss_access" ];
          valuesByGroup."firefly.access" = [ "firefly_access" ];
          valuesByGroup."ollama.access" = [ "ollama_access" ];
          valuesByGroup."octoprint.access" = [ "octoprint_access" ];
          valuesByGroup."invidious.access" = [ "invidious_access" ];
        };
      };

      groups."forgejo.access" = {
        members = [ "forgejo.admins" ];
      };
      groups."forgejo.admins" = {
        members = [ "administrator" ];
      };
      systems.oauth2.forgejo = {
        displayName = "Forgejo";
        originUrl = "https://forge.${config.secrets.secrets.global.domains.web}/user/oauth2/kanidm/callback";
        originLanding = "https://forge.${config.secrets.secrets.global.domains.web}/";
        basicSecretFile = config.age.secrets.oauth2-forgejo.path;
        scopeMaps."forgejo.access" = [
          "openid"
          "email"
          "profile"
        ];
        allowInsecureClientDisablePkce = true;
        preferShortUsername = true;
        claimMaps.groups = {
          joinType = "array";
          valuesByGroup."forgejo.admins" = [ "admin" ];
        };
      };

      groups."netbird.access" = { };
      systems.oauth2.netbird = {
        public = true;
        displayName = "Netbird";
        originUrl = "https://netbird.${config.secrets.secrets.global.domains.web}/";
        originLanding = "https://netbird.${config.secrets.secrets.global.domains.web}/";
        preferShortUsername = true;
        enableLocalhostRedirects = true;
        enableLegacyCrypto = true;
        scopeMaps."netbird.access" = [
          "openid"
          "email"
          "profile"
        ];
      };
    };
  };
  systemd.services.kanidm.serviceConfig.RestartSec = "60"; # Retry every minute
}
