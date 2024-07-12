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
      forgejo = "forge";
      immich = "immich";
      nextcloud = "nc";
      ollama = "ai";
      paperless = "ppl";
      ttrss = "rss";
      vaultwarden = "pw";
      yourspotify = "sptfy";
      apispotify = "apisptfy";
      kanidm = "auth";
      oauth2-proxy = "oauth2";
      netbird = "netbird";
      actual = "actual";
      firefly = "money";
      homebox = "homebox";
      octoprint = "print";
    };
  in "${domains.${hostName}}.${config.secrets.secrets.global.domains.web}";
  # TODO hard coded elisabeth nicht so schön
  ipOf = hostName:
    if nodes ? ${hostName}
    then nodes.${hostName}.config.wireguard.elisabeth.ipv4
    else nodes."elisabeth-${hostName}".config.wireguard.elisabeth.ipv4;
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
    proxyProtect = hostName: cfg: allowedGroup:
      lib.mkMerge [
        (blockOf hostName cfg)
        {
          virtualHosts.${domainOf hostName} = {
            locations."/".extraConfig = ''
              auth_request /oauth2/auth;
              error_page 401 = /oauth2/sign_in;

              # pass information via X-User and X-Email headers to backend,
              # requires running with --set-xauthrequest flag
              auth_request_set $user   $upstream_http_x_auth_request_preferred_username;
              # Set the email to our own domain in case user change their mail
              auth_request_set $email  "''${upstream_http_x_auth_request_preferred_username}@${config.secrets.secrets.global.domains.web}";
              proxy_set_header X-User  $user;
              proxy_set_header X-Email $email;

              # if you enabled --cookie-refresh, this is needed for it to work with auth_request
              auth_request_set $auth_cookie $upstream_http_set_cookie;
              add_header Set-Cookie $auth_cookie;
            '';
            locations."/oauth2/" = {
              proxyPass = "http://oauth2-proxy";
              extraConfig = ''
                proxy_set_header X-Scheme                $scheme;
                proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
              '';
            };

            locations."= /oauth2/auth" = {
              proxyPass = "http://oauth2-proxy/oauth2/auth" + lib.optionalString allowedGroup "?allowed_groups=${hostName}_access";
              extraConfig = ''
                internal;

                proxy_set_header X-Scheme         $scheme;
                # nginx auth_request includes headers but not body
                proxy_set_header Content-Length   "";
                proxy_pass_request_body           off;
              '';
            };
          };
        }
      ];
  in
    lib.mkMerge [
      {
        enable = true;
        recommendedSetup = true;
        upstreams.netbird = {
          servers."${ipOf "netbird"}:80" = {};
          extraConfig = ''
            zone netbird 64k ;
            keepalive 5 ;
          '';
        };
        upstreams.netbird-mgmt = {
          servers."${ipOf "netbird"}:3000" = {};
          extraConfig = ''
            zone netbird 64k ;
            keepalive 5 ;
          '';
        };
        virtualHosts.${domainOf "netbird"} = {
          forceSSL = true;
          useACMEHost = "web";
          locations = {
            "/" = {
              proxyPass = "http://netbird";
              proxyWebsockets = true;
              X-Frame-Options = "SAMEORIGIN";
            };
            "/signalexchange.SignalExchange/".extraConfig = ''
              grpc_pass grpc://${ipOf "netbird"}:3001;
              grpc_read_timeout 1d;
              grpc_send_timeout 1d;
              grpc_socket_keepalive on;
            '';

            "/api".proxyPass = "http://netbird-mgmt";

            "/management.ManagementService/".extraConfig = ''
              grpc_pass grpc://${ipOf "netbird"}:3000;
              grpc_read_timeout 1d;
              grpc_send_timeout 1d;
              grpc_socket_keepalive on;
            '';
          };
          extraConfig = ''
            client_max_body_size 500M ;
            client_header_timeout 1d;
            client_body_timeout 1d;
          '';
        };
      }
      (blockOf "vaultwarden" {maxBodySize = "1G";})
      (blockOf "forgejo" {maxBodySize = "1G";})
      (blockOf "immich" {maxBodySize = "5G";})
      (proxyProtect "adguardhome" {} true)
      (proxyProtect "oauth2-proxy" {} false)
      (blockOf "paperless" {maxBodySize = "5G";})
      (proxyProtect "ttrss" {port = 80;} true)
      (blockOf "yourspotify" {port = 80;})
      #(blockOf "homebox" {})
      (proxyProtect "ollama" {} true)
      (proxyProtect "octoprint" {} true)
      (proxyProtect "firefly" {port = 80;} true)
      (blockOf "apispotify" {
        port = 3000;
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
        ../../config/basic
        ../../config/services/${guestName}.nix
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
    // mkContainer "oauth2-proxy" {}
    // mkContainer "vaultwarden" {}
    // mkContainer "ddclient" {}
    // mkContainer "ollama" {}
    // mkContainer "murmur" {}
    #// mkContainer "homebox" {}
    // mkContainer "ttrss" {}
    // mkContainer "firefly" {}
    // mkContainer "yourspotify" {}
    // mkContainer "netbird" {}
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
