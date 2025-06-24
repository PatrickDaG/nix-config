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
  networking.nftables.firewall = {
    zones = {
      tailscale.interfaces = [ "tailscale0" ];
      services = {
        ipv4Addresses = [ globals.net.vlans.services.cidrv4 ];
      };
    };
    rules.forward-tailscale = {
      from = [ "tailscale" ];
      to = [ "services" ];
      verdict = "accept";
    };
  };
  networking.firewall.allowedUDPPorts = [
    3478
    (config.services.tailscale.port)
  ]; # STUN/TURN server
  services.headscale = {
    enable = true;
    port = 3000;
    address = "0.0.0.0";
    settings = {
      server_url = "https://${globals.services.headscale.domain}";
      dns = {
        base_domain = "internal";
        nameservers.split."lel.lol" = [ "10.99.20.10" ];
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
        #urls = [ ]; # Don't use tailscale DERP server
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
        acls = [
          {
            action = "accept";
            src = [ "*" ];
            dst = [ "*:*" ];
          }
        ];
        autoApprovers.routes."10.99.20.0/24" = [ "tag:server" ];
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
    {
      directory = "/var/lib/tailscale";
      mode = "750";
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
      "--advertise-routes=10.99.20.0/24"
    ];
  };
}
