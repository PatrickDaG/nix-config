{
  config,
  globals,
  lib,
  nodes,
  ...
}:
let
  # TODO: automatically assign these somehow
  homeDomains = [
    globals.services.jellyfin.domain
    globals.services.immich.domain
    globals.services.influxdb.domain
    globals.services.loki.domain
    globals.services.paperless.domain
    globals.services.esphome.domain
    globals.services.homeassistant.domain
    globals.services.firefly.domain
    "fritzbox.${globals.domains.web}"
  ];

  allow = group: resource: {
    "${group}@${resource}" = {
      inherit group resource;
      description = "Allow ${group} access to ${resource}";
    };
  };
in
{
  age.secrets.admin-passwd = {
    generator.script = "alnum";
    intermediary = true;
  };

  age.secrets.admin-passwd-hash = {
    generator.dependencies = [ config.age.secrets.admin-passwd ];
    generator.script = "argon2id";
    mode = "440";
  };
  globals.wireguard.services-extern.hosts.${config.node.name} = {
    firewallRuleForNode.torweg-nginx.allowedTCPPorts = [
      config.services.firezone.server.apiPort
      config.services.firezone.server.webPort
    ];
  };
  age.secrets.firezone-smtp-password.generator.script = "alnum";

  # NOTE: state: this token is a manually created relay token
  age.secrets.firezone-relay-token = {
    rekeyFile = config.node.secretsDir + "/firezone-relay-token.age";
  };

  # Mirror the original oauth2 secret
  age.secrets.firezone-oauth2-client-secret = {
    inherit (nodes.${globals.services.kanidm.host}.config.age.secrets.oauth2-firezone) rekeyFile;
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/firezone";
      mode = "0700";
    }
  ];

  # globals.monitoring.http.firezone = {
  #   url = "https://${globals.services.firezone.domain}/";
  #   network = "internet";
  #   expectedBodyRegex = "Welcome to Firezone";
  # };

  services.firezone.server = {
    enable = true;
    enableLocalDB = true;

    smtp = {
      username = "firezone@${globals.domains.mail_public}";
      from = "firezone@${globals.domains.mail_public}";
      host = "smtp.${globals.domains.mail_public}";
      port = 465;
      implicitTls = true;
      passwordFile = config.age.secrets.firezone-smtp-password.path;
    };
    settings.HEALTH_PORT = 4001;

    provision = {
      enable = true;
      accounts.main = {
        name = "Home";
        gatewayGroups.home.name = "Home";
        actors.admin = {
          type = "account_admin_user";
          name = "Admin";
          email = "firezone_admin@${globals.domains.mail_public}";
          passwordHash._secret = config.age.secrets.admin-passwd-hash.path;
        };
        groups.anyone = {
          name = "anyone";
          members = [
            "admin"
          ];
        };

        auth.oidc.kanidm =
          let
            client_id = "firezone";
          in
          {
            name = "kanidm";
            inherit client_id;
            issuer = "https://auth.${globals.domains.web}/oauth2/openid/${client_id}";
            discovery_document_uri = "https://${globals.services.kanidm.domain}/oauth2/openid/${client_id}/.well-known/openid-configuration";
            client_secret._secret = config.age.secrets.firezone-oauth2-client-secret.path;
          };

        resources =
          lib.genAttrs homeDomains (domain: {
            type = "dns";
            name = domain;
            address = domain;
            gatewayGroups = [ "home" ];
            filters = [
              { protocol = "icmp"; }
              {
                protocol = "tcp";
                ports = [
                  443
                  80
                ];
              }
              {
                protocol = "udp";
                ports = [ 443 ];
              }
            ];
          })
          // {
            "house.lan.v4" = {
              type = "cidr";
              name = "house.lan.v4";
              address = globals.net.vlans.house.cidrv4;
              gatewayGroups = [ "home" ];
            };
            "smb.internal" = {
              type = "dns";
              name = "smb.internal";
              address = "smb.internal";
              gatewayGroups = [ "home" ];
              filters = [
                { protocol = "icmp"; }
                {
                  protocol = "tcp";
                  ports = [
                    445
                  ];
                }
              ];
            };
            "house.lan.v6" = {
              type = "cidr";
              name = "house.lan.v6";
              address = globals.net.vlans.house.cidrv6;
              gatewayGroups = [ "home" ];
            };
          };

        policies =
          { }
          // allow "anyone" "house.lan.v4"
          // allow "everyone" "house.lan.v4"
          // allow "anyone" "house.lan.v6"
          // allow "everyone" "house.lan.v6"
          // lib.mergeAttrsList (map (domain: allow "anyone" domain) homeDomains)
          // lib.mergeAttrsList (map (domain: allow "everyone" domain) homeDomains);
      };
    };

    portal = {
      externalUrl = "https://${globals.services.firezone.domain}/";
      port = 3000;
      address = "0.0.0.0";
    };
  };

  services.firezone.relay = {
    enable = true;
    name = "torweg";
    apiUrl = "wss://${globals.services.firezone.domain}/api/";
    tokenFile = config.age.secrets.firezone-relay-token.path;
    publicIpv4 = lib.net.cidr.ip config.secrets.secrets.local.networking.interfaces.lan01.hostCidrv4;
    publicIpv6 = lib.net.cidr.ip config.secrets.secrets.local.networking.interfaces.lan01.hostCidrv6;
    openFirewall = true;
  };

  systemd.services.firezone-relay.environment.HEALTH_CHECK_ADDR = "127.0.0.1:17999";

}
