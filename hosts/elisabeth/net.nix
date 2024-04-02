{
  config,
  lib,
  ...
}: {
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network.networks = {
    "10-lan01" = {
      address = [(lib.net.cidr.hostCidr config.secrets.secrets.global.net.ips.${config.node.name} config.secrets.secrets.global.net.privateSubnetv4)];
      gateway = [(lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnetv4)];
      #matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
      matchConfig.Name = "lan";
      dhcpV6Config.UseDNS = false;
      dhcpV4Config.UseDNS = false;
      ipv6AcceptRAConfig.UseDNS = false;
      networkConfig = {
        MulticastDNS = true;
      };
    };
    "40-lan01" = {
      dhcpV6Config.UseDNS = false;
      dhcpV4Config.UseDNS = false;
      ipv6AcceptRAConfig.UseDNS = false;
      networkConfig = {
        MulticastDNS = true;
      };
    };
  };
  boot.initrd.systemd.network = {
    enable = true;
    networks = {
      # redo the network cause the livesystem has macvlans
      "10-lan01" = {
        address = [(lib.net.cidr.hostCidr config.secrets.secrets.global.net.ips.${config.node.name} config.secrets.secrets.global.net.privateSubnetv4)];
        gateway = [(lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnetv4)];
        matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
        dhcpV6Config.UseDNS = false;
        dhcpV4Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;
        networkConfig = {
          IPv6PrivacyExtensions = "yes";
          MulticastDNS = true;
        };
      };
    };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = ["lan"];

  wireguard.elisabeth.server = {
    host = lib.net.cidr.host config.secrets.secrets.global.net.ips.${config.node.name} config.secrets.secrets.global.net.privateSubnetv4;
    reservedAddresses = ["10.42.0.0/20" "fd00:1764::/112"];
    openFirewall = true;
  };
  # To be able to ping containers from the host, it is necessary
  # to create a macvlan on the host on the VLAN 1 network.
  networking.macvlans.lan = {
    interface = "lan01";
    mode = "bridge";
  };

  age.secrets.cloudflare_token_acme = {
    rekeyFile = ./secrets/cloudflare_api_token.age;
    mode = "440";
    group = "acme";
  };
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.secrets.secrets.global.devEmail;
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      reloadServices = ["nginx"];
      credentialFiles = {
        "CF_DNS_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
        "CF_ZONE_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
      };
    };
  };
  security.acme.certs.web = {
    domain = config.secrets.secrets.global.domains.web;
    extraDomainNames = ["*.${config.secrets.secrets.global.domains.web}"];
  };
  users.groups.acme.members = ["nginx"];
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/acme";
      user = "acme";
      group = "acme";
      mode = "0755";
    }
  ];
}
