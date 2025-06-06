{
  globals,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./oauth2-proxy.nix ];
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 3000 ];
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
    oauth2-headscale = {
      generator.script = "alnum";
      mode = "440";
      group = "kanidm";
    };
    oauth2-grafana = {
      generator.script = "alnum";
      mode = "440";
      group = "kanidm";
    };
  };
  services.kanidm = {
    package = pkgs.kanidm.withSecretProvisioning;
    enableServer = true;
    serverSettings = {
      inherit (globals.services.kanidm) domain;
      origin = "https://${globals.services.kanidm.domain}";
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
        originUrl = "https://${globals.services.paperless.domain}/accounts/oidc/kanidm/login/callback/";
        originLanding = "https://${globals.services.paperless.domain}/";
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
        originUrl = "https://${globals.services.nextcloud.domain}/";
        originLanding = "https://${globals.services.nextcloud.domain}/";
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
        originUrl = [
          "https://${globals.services.immich.domain}/auth/login"
          "https://${globals.services.immich.domain}/api/oauth/mobile-redirect"
        ];
        originLanding = "https://${globals.services.immich.domain}/";
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

      groups."grafana.access" = {
        members = [ "grafana.admins" ];
      };
      groups."grafana.admins" = {
        members = [ "administrator" ];
      };
      systems.oauth2.grafana = {
        displayName = "grafana";
        originUrl = "https://${globals.services.grafana.domain}/login/generic_oauth";
        originLanding = "https://${globals.services.grafana.domain}/";
        basicSecretFile = config.age.secrets.oauth2-grafana.path;
        scopeMaps."grafana.access" = [
          "openid"
          "email"
          "profile"
        ];
        allowInsecureClientDisablePkce = true;
        preferShortUsername = true;
        claimMaps.groups = {
          joinType = "array";
          valuesByGroup."grafana.admins" = [ "admin" ];
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
        originUrl = "https://${globals.services.forgejo.domain}/user/oauth2/kanidm/callback";
        originLanding = "https://${globals.services.forgejo.domain}/";
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
        originUrl = [
          "https://${globals.services.netbird.domain}/peers"
          "https://${globals.services.netbird.domain}/add-peers"
        ];
        originLanding = "https://${globals.services.netbird.domain}/";
        preferShortUsername = true;
        enableLocalhostRedirects = true;
        enableLegacyCrypto = true;
        scopeMaps."netbird.access" = [
          "openid"
          "email"
          "profile"
        ];
      };

      groups."headscale.access" = { };
      systems.oauth2.headscale = {
        displayName = "headscale";
        originUrl = [
          "https://${globals.services.headscale.domain}/oidc/callback"
        ];
        basicSecretFile = config.age.secrets.oauth2-headscale.path;
        originLanding = "https://${globals.services.headscale.domain}/";
        scopeMaps."headscale.access" = [
          "openid"
          "email"
          "profile"
        ];
      };

      # oauth2 proxy groups
      groups."rss.access" = { };
      groups."firefly.access" = { };
      groups."fireflypico.access" = { };
      groups."ollama.access" = { };
      groups."adguardhome.access" = { };
      groups."octoprint.access" = { };
      groups."invidious.access" = { };
      groups."esphome.access" = { };

      systems.oauth2.oauth2-proxy = {
        displayName = "Oauth2-Proxy";
        originUrl = "https://${globals.services.oauth2-proxy.domain}/oauth2/callback";
        originLanding = "https://${globals.services.oauth2-proxy.domain}/";
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
        scopeMaps."fireflypico.access" = [
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
        scopeMaps."esphome.access" = [
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
          valuesByGroup."fireflypico.access" = [ "fireflypico_access" ];
          valuesByGroup."ollama.access" = [ "ollama_access" ];
          valuesByGroup."octoprint.access" = [ "octoprint_access" ];
          valuesByGroup."invidious.access" = [ "invidious_access" ];
          valuesByGroup."esphome.access" = [ "esphome_access" ];
        };
      };
    };
  };
  systemd.services.kanidm.serviceConfig.RestartSec = "60"; # Retry every minute
}
