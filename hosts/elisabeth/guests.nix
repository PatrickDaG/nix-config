{
  config,
  stateVersion,
  inputs,
  lib,
  minimal,
  nodes,
  ...
}: let
  domainOf = hostName: let
    domains = {
      adguardhome = "adguardhome";
      forgejo = "git";
      immich = "immich";
      nextcloud = "nc";
      ollama = "ollama";
      paperless = "ppl";
      ttrss = "rss";
      vaultwarden = "pw";
      yourspotify = "sptfy";
      apispotify = "apisptfy";
      kanidm = "auth";
    };
  in "${domains.${hostName}}.${config.secrets.secrets.global.domains.web}";
  # TODO hard coded elisabeth nicht so schön
  ipOf = hostName: nodes."elisabeth-${hostName}".config.wireguard.elisabeth.ipv4;
in {
  services.nginx = let
    blockOf = hostName: {
      virtualHostExtraConfig ? "",
      maxBodySize ? "500M",
      port ? 3000,
      upstream ? hostName,
      protocol ? "http",
    }: {
      upstreams.${hostName} = {
        servers."${ipOf upstream}:${toString port}" = {};
        extraConfig = ''
          zone ${hostName} 64k ;
          keepalive 5 ;
        '';
      };
      virtualHosts.${domainOf hostName} = {
        forceSSL = true;
        useACMEHost = "web";
        locations."/" = {
          proxyPass = "${protocol}://${hostName}";
          proxyWebsockets = true;
          X-Frame-Options = "SAMEORIGIN";
        };
        extraConfig =
          ''
            client_max_body_size ${maxBodySize} ;
          ''
          + virtualHostExtraConfig;
      };
    };
  in
    lib.mkMerge [
      {
        enable = true;
        recommendedSetup = true;
      }
      (blockOf "vaultwarden" {maxBodySize = "1G";})
      (blockOf "forgejo" {maxBodySize = "1G";})
      (blockOf "immich" {maxBodySize = "5G";})
      (
        blockOf "adguardhome"
        {
          virtualHostExtraConfig = ''
            allow ${config.secrets.secrets.global.net.privateSubnetv4};
            allow ${config.secrets.secrets.global.net.privateSubnetv6};
            deny all ;
          '';
        }
      )
      (blockOf "paperless" {maxBodySize = "5G";})
      (blockOf "ttrss" {port = 80;})
      (blockOf "yourspotify" {port = 80;})
      (blockOf "apispotify" {
        port = 80;
        upstream = "yourspotify";
      })
      (blockOf "nextcloud" {
        maxBodySize = "5G";
        port = 80;
      })
      (blockOf "kanidm"
        {
          protocol = "https";
          virtualHostExtraConfig = ''
            proxy_ssl_verify off ;
          '';
        })
    ];

  guests = let
    mkGuest = guestName: {
      enablePanzer ? false,
      enableRenaultFT ? false,
      enableBunker ? false,
      enableSharedPaperless ? false,
      ...
    }: {
      autostart = true;
      zfs."/state" = {
        pool = "rpool";
        dataset = "local/guests/${guestName}";
      };
      zfs."/persist" = {
        pool = "rpool";
        dataset = "safe/guests/${guestName}";
      };
      zfs."/panzer" = lib.mkIf enablePanzer {
        pool = "panzer";
        dataset = "safe/guests/${guestName}";
      };
      zfs."/renaultft" = lib.mkIf enableRenaultFT {
        pool = "renaultft";
        dataset = "safe/guests/${guestName}";
      };
      # kinda not necesarry should be removed on next reimaging
      zfs."/bunker" = lib.mkIf enableBunker {
        pool = "panzer";
        dataset = "bunker/guests/${guestName}";
      };
      zfs."/paperless" = lib.mkIf enableSharedPaperless {
        pool = "panzer";
        dataset = "bunker/shared/paperless";
      };
      modules = [
        ../../modules/config
        ../../modules/services/${guestName}.nix
        {
          node.secretsDir = config.node.secretsDir + "/${guestName}";
          networking.nftables.firewall.zones.untrusted.interfaces = [config.guests.${guestName}.networking.mainLinkName];
          systemd.network.networks."10-${config.guests.${guestName}.networking.mainLinkName}" = {
            DHCP = lib.mkForce "no";
            address = [
              (lib.net.cidr.hostCidr config.secrets.secrets.global.net.ips."${config.guests.${guestName}.nodeName}" config.secrets.secrets.global.net.privateSubnetv4)
              (lib.net.cidr.hostCidr config.secrets.secrets.global.net.ips."${config.guests.${guestName}.nodeName}" config.secrets.secrets.global.net.privateSubnetv6)
            ];
            gateway = [(lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnetv4)];
          };
        }
      ];
    };

    #deadnix: skip
    mkMicrovm = guestName: cfg: {
      ${guestName} =
        mkGuest guestName cfg
        // {
          backend = "microvm";
          microvm = {
            system = "x86_64-linux";
            macvtap = "lan";
            baseMac = config.secrets.secrets.local.networking.interfaces.lan01.mac;
          };
          extraSpecialArgs = {
            inherit (inputs.self) nodes;
            inherit (inputs.self.pkgs.x86_64-linux) lib;
            inherit inputs minimal stateVersion;
          };
        };
    };

    mkContainer = guestName: cfg: {
      ${guestName} =
        mkGuest guestName cfg
        // {
          backend = "container";
          container.macvlan = "lan";
          extraSpecialArgs = {
            inherit lib nodes inputs minimal stateVersion;
          };
        };
    };
  in
    {}
    // mkContainer "adguardhome" {}
    // mkContainer "vaultwarden" {}
    // mkContainer "ddclient" {}
    // mkContainer "ollama" {}
    // mkContainer "ttrss" {}
    // mkContainer "yourspotify" {}
    // mkContainer "kanidm" {}
    // mkContainer "nextcloud" {
      enablePanzer = true;
    }
    // mkContainer "paperless" {
      enableSharedPaperless = true;
    }
    // mkContainer "forgejo" {
      enablePanzer = true;
    }
    // mkMicrovm "immich" {
      enablePanzer = true;
    }
    // mkContainer "samba" {
      enablePanzer = true;
      enableRenaultFT = true;
      enableBunker = true;
      enableSharedPaperless = true;
    };
}
