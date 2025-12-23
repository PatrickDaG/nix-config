{
  lib,
  config,
  globals,
  ...
}:
{
  networking.nftables = {
    firewall = {
      zones = {
        firezone.interfaces = [ "tun-firezone" ];
      };
      # masquerade firezone traffic
      rules = {
        masquerade-firezone = {
          from = [ "firezone" ];
          to = [ "untrusted" ];
          # masquerade = true; NOTE: custom rule below for ip4 + ip6
          late = true; # Only accept after any rejects have been processed
          verdict = "accept";
        };
      };
    };
    chains.postrouting = {
      masquerade-firezone = {
        after = [ "hook" ];
        late = true;
        rules = lib.singleton (
          lib.concatStringsSep " " [
            "meta protocol { ip, ip6 }"
            (lib.head config.networking.nftables.firewall.zones.firezone.ingressExpression)
            (lib.head config.networking.nftables.firewall.zones.untrusted.egressExpression)
            "masquerade random"
          ]
        );
      };
    };
  };
  # NOTE: state: this token is a manually created gateway token
  age.secrets.firezone-gateway-token = {
    rekeyFile = config.node.secretsDir + "/firezone-gateway-token.age";
  };
  services.firezone.gateway = {
    enable = true;
    name = "nucnix"; # Oupsi
    apiUrl = "wss://${globals.services.firezone.domain}/api/";
    tokenFile = config.age.secrets.firezone-gateway-token.path;
  };
  systemd.services.firezone-gateway.environment = {
    FIREZONE_NO_INC_BUF = "true";
  };

  systemd.network.networks."10-mv-home" = {
    DHCP = "yes";
    # XXX: Do we really want this?
    dhcpV4Config.UseDNS = lib.mkForce true;
    dhcpV6Config.UseDNS = lib.mkForce true;
    ipv6AcceptRAConfig.UseDNS = lib.mkForce true;
  };
}
