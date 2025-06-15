{
  globals,
  config,
  nodes,
  pkgs,
  ...
}:
{
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ config.services.headscale.port ];
  };
  networking.firewall.allowedUDPPorts = [
    3478
  ]; # STUN/TURN server
  services.headscale = {
    enable = true;
    port = 3000;
    address = "0.0.0.0";
    settings = {
      server_url = "https://${globals.services.headscale.domain}";
      dns = {
        base_domain = "internal.${globals.domains.web}";
        nameservers.split.${globals.domains.web} = [ "10.99.20.10" ];
        override_local_dns = false;
      };
      oidc = {
        client_id = "headscale";
        client_secret_path = config.age.secrets.openid-secret.path;
        issuer = "https://${globals.services.kanidm.domain}/oauth2/openid/headscale";
        # Why default disabled?
        pkce.enabled = true;
      };
      # relay server
      derp.server = {
        enabled = true;
        urls = [ ]; # Don't use tailscale DERP server
        stun_listen_addr = "0.0.0.0:3478";
      };
      policy.path = (pkgs.formats.json { }).generate "headscale.json" {
        tagOwners = {
          "tag:server" = [
            "patrick@"
          ];
          "tag:desktopnix" = [
            "patrick@"
          ];
        };
        # acls = [
        #   {
        #     action = "accept";
        #     src = [ "*" ];
        #     dst = [ "*:*" ];
        #   }
        # ];
        autoApprovers.routes."10.99.0.0/16" = [ "tag:server" ];
      };
    };
  };
  age.secrets.openid-secret = {
    inherit (nodes.${globals.services.kanidm.host}.config.age.secrets.oauth2-headscale) rekeyFile;
    mode = "440";
    inherit (config.services.headscale) group;
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/headscale";
      mode = "770";
      user = "headscale";
      group = "headscale";
    }
  ];

  # generated using
  # 'headscale preauthkeys create -e 99y --reusable -u 1 --tags "tag:server"'
  age.secrets.authKeyFile = {
    rekeyFile = config.node.secretsDir + "/authkey.age";
  };
  services.tailscale = {
    enable = true;
    extraDaemonFlags = [ "--no-logs-no-support" ];
    disableTaildrop = true;
    useRoutingFeatures = "server";
    openFirewall = true;
    authKeyFile = config.age.secrets.authKeyFile.path;
    extraUpFlags = [
      "--login-server=${"https://${globals.services.headscale.domain}"}"
      "--advertise-routes=10.99.0.0/16"
    ];
  };
  environment.persistence."/state".files = [
    {
      file = "/var/lib/tailscale/tailscaled.state";
      parentDirectory = {
        mode = "750";
      };
    }
  ];
}
