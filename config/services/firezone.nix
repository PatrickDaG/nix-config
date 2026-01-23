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
    inherit (nodes.nucnix-kanidm.config.age.secrets.oauth2-firezone) rekeyFile;
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

    provision = {
      enable = true;
      accounts.main = {
        name = "Home";
        gatewayGroups.home.name = "Home";
        actors.admin = {
          type = "account_admin_user";
          name = "Admin";
          email = "firezone_admin@${globals.domains.mail_public}";
          #allow_email_otp_sign_in = true;
        };
        groups.anyone = {
          name = "anyone";
          members = [
            "admin"
          ];
        };

        auth.oidc =
          let
            client_id = "firezone";
          in
          {
            name = "Kanidm";
            adapter = "openid_connect";
            adapter_config = {
              scope = "openid email profile";
              response_type = "code";
              inherit client_id;
              discovery_document_uri = "https://${globals.services.kanidm.domain}/oauth2/openid/${client_id}/.well-known/openid-configuration";
              clientSecretFile = config.age.secrets.firezone-oauth2-client-secret.path;
            };
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
            "home.vlan-services.v4" = {
              type = "cidr";
              name = "home.vlan-services.v4";
              address = globals.net.vlans.services.cidrv4;
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
            "home.vlan-services.v6" = {
              type = "cidr";
              name = "home.vlan-services.v6";
              address = globals.net.vlans.services.cidrv6;
              gatewayGroups = [ "home" ];
            };
          };

        policies =
          { }
          // allow "anyone" "home.vlan-services.v4"
          // allow "everyone" "home.vlan-services.v4"
          // allow "anyone" "home.vlan-services.v6"
          // allow "everyone" "home.vlan-services.v6"
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
