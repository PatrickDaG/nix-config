{
  config,
  lib,
  globals,
  ...
}:
let
  icfg = config.secrets.secrets.local.networking.interfaces.lan01;
in
{
  networking.hostId = config.secrets.secrets.local.networking.hostId;
  networking.domain = globals.domains.mail_public;

  boot.initrd.systemd.network = {
    enable = true;
    networks = {
      inherit (config.systemd.network.networks) "lan01";
    };
  };

  systemd.network.networks = {
    "lan01" = {
      address = [
        icfg.hostCidrv4
        (lib.net.cidr.hostCidr 1 icfg.hostCidrv6)
      ];
      gateway = [ "fe80::1" ];
      routes = [
        { Destination = "172.31.1.1"; }
        {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        }
      ];
      matchConfig.MACAddress = icfg.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      linkConfig.RequiredForOnline = "routable";
    };
  };
  age.secrets.cloudflare_token_acme = {
    rekeyFile = ./secrets/cloudflare_api_token.age;
    mode = "440";
    group = "acme";
  };
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = globals.accounts.email."1".address;
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      reloadServices = [ "nginx" ];
      credentialFiles = {
        "CF_DNS_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
        "CF_ZONE_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
      };
    };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan01" ];
  users.groups.acme.members = [ "nginx" ];
  security.acme.certs = {
    "${globals.domains.mail_public}" = {
      domain = globals.domains.mail_public;
      extraDomainNames = [ "*.${globals.domains.mail_public}" ];
    };
  };
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/acme";
      user = "acme";
      group = "acme";
      mode = "0755";
    }
  ];
  meta.telegraf.availableMonitoringNetworks = [
    "internet"
  ];
  globals.monitoring.ping.mailnix = {
    hostv4 = lib.net.cidr.ip icfg.hostCidrv4;
    hostv6 = lib.net.cidr.ip (lib.net.cidr.hostCidr 1 icfg.hostCidrv6);
    network = "internet";
  };

}
