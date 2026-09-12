{
  config,
  lib,
  ...
}:
{
  networking.hostId = config.secrets.secrets.local.networking.hostId;

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  systemd.network.netdevs = {
    "50-macvlan-house" = {
      netdevConfig = {
        Name = "lan-house";
        Kind = "macvlan";
      };
      extraConfig = ''
        [MACVLAN]
        Mode=bridge
      '';
    };
  };
  systemd.network.networks = {
    "10-lan-house" = {
      matchConfig.Name = "lan01";
      # This interface should only be used from attached macvtaps.
      # So don't acquire a link local address and only wait for
      # this interface to gain a carrier.
      networkConfig.LinkLocalAddressing = "no";
      linkConfig.RequiredForOnline = "carrier";
      extraConfig = ''
        [Network]
        MACVLAN=lan-house
      '';
    };
    "20-lan-house" = {
      matchConfig.Name = "lan-house";
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        DHCP = "no";
      };
      gateway = [
        (lib.net.cidr.host 1 "192.168.178.0/24")
        (lib.net.cidr.host 1 "fd7a:3539:5f0e:0::/64")
      ];
      address = [
        (lib.net.cidr.hostCidr 2 "192.168.178.0/24")
        (lib.net.cidr.hostCidr 2 "fd7a:3539:5f0e:0::/64")
      ];
    };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan-house" ];
  boot.initrd = {

    availableKernelModules = [
      "8021q"
    ];
    systemd.network = {
      enable = true;
      networks = {
        # redo the network cause the livesystem has macvlans
        "10-lan01" = {
          matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
            DHCP = "no";
          };
          gateway = [
            (lib.net.cidr.host 1 "192.168.178.0/24")
            (lib.net.cidr.host 1 "fd7a:3539:5f0e:0::/64")
          ];
          address = [
            (lib.net.cidr.hostCidr 2 "192.168.178.0/24")
            (lib.net.cidr.hostCidr 2 "fd7a:3539:5f0e:0::/64")
          ];
        };
      };
    };
  };
  # age.secrets.cloudflare_token_acme = {
  #   rekeyFile = ./secrets/cloudflare_api_token.age;
  #   mode = "440";
  #   group = "acme";
  # };
  # security.acme = {
  #   acceptTerms = true;
  #   defaults = {
  #     email = globals.accounts.email."1".address;
  #     dnsProvider = "cloudflare";
  #     dnsPropagationCheck = true;
  #     reloadServices = [
  #       "nginx"
  #       "stalwart-mail"
  #     ];
  #     credentialFiles = {
  #       "CF_DNS_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
  #       "CF_ZONE_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
  #     };
  #   };
  # };
  # users.groups.acme.members = [ "nginx" ];
  # security.acme.certs = {
  #   "${globals.domains.mail_public}" = {
  #     domain = globals.domains.mail_public;
  #     extraDomainNames = [ "*.${globals.domains.mail_public}" ];
  #   };
  # };
  # environment.persistence."/state".directories = [
  #   {
  #     directory = "/var/lib/acme";
  #     user = "acme";
  #     group = "acme";
  #     mode = "0755";
  #   }
  # ];
}
