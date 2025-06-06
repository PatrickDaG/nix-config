{
  config,
  nodes,
  lib,
  globals,
  ...
}:
let
  ipOf = name: globals.wireguard.services.hosts.${globals.services.${name}.host}.ipv4;
  blockOf =
    hostName:
    {
      virtualHostExtraConfig ? "",
      maxBodySize ? "500M",
      port ? 3000,
      upstream ? hostName,
      protocol ? "http",
      ...
    }:
    {
      upstreams.${hostName} = {
        servers."${ipOf upstream}:${toString port}" = { };
        extraConfig = ''
          zone ${hostName} 64k ;
          keepalive 5 ;
        '';
        monitoring = {
          enable = true;
          expectedBodyRegex = hostName;
        };
      };
      virtualHosts.${globals.services.${hostName}.domain} = {
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
  proxyProtect =
    hostName:
    {
      allowedGroup ? true,
      ...
    }@cfg:
    lib.mkMerge [
      (blockOf hostName cfg)
      {
        virtualHosts.${globals.services.${hostName}.domain} = {
          locations."/".extraConfig = ''
            auth_request /oauth2/auth;
            error_page 401 = /oauth2/sign_in;

            # pass information via X-User and X-Email headers to backend,
            # requires running with --set-xauthrequest flag
            auth_request_set $user   $upstream_http_x_auth_request_preferred_username;
            # Set the email to our own domain in case user change their mail
            auth_request_set $email  "''${upstream_http_x_auth_request_preferred_username}@${globals.domains.web}";
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
            proxyPass =
              "http://oauth2-proxy/oauth2/auth"
              + lib.optionalString allowedGroup "?allowed_groups=${hostName}_access";
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
{
  globals.wireguard.services.hosts.${config.node.name} = { };
  age.secrets.loki-basic-auth-hashes = {
    inherit (nodes.${globals.services.loki.host}.config.age.secrets.loki-basic-auth-hashes) rekeyFile;
    mode = "440";
    group = "nginx";
  };
  services.nginx = lib.mkMerge [
    {
      enable = true;
      recommendedSetup = true;
      virtualHosts."${globals.services.netbird.domain}".useACMEHost = "web";
      upstreams.fritz = {
        servers."${lib.net.cidr.host 1 "10.99.2.0/24"}:443" = { };
        extraConfig = ''
          zone fritz 64k ;
          keepalive 5 ;
        '';
      };
      virtualHosts.${globals.services.fritz.domain} = {
        forceSSL = true;
        useACMEHost = "web";
        locations."/" = {
          proxyPass = "https://fritz";
          proxyWebsockets = true;
          X-Frame-Options = "SAMEORIGIN";
        };
        extraConfig = ''
          client_max_body_size 512M ;
          proxy_ssl_verify off ;
          allow ${globals.net.vlans.home.cidrv4} ;
          allow ${globals.net.vlans.home.cidrv6} ;
          deny all ;
        '';
      };

      upstreams.loki = {
        servers."${globals.wireguard.services.hosts.${globals.services.loki.host}.ipv4}:${
          toString
            nodes.${globals.services.loki.host}.config.services.loki.configuration.server.http_listen_port
        }" =
          { };
        extraConfig = ''
          zone loki 64k;
          keepalive 2;
        '';
      };
      virtualHosts.${globals.services.loki.domain} = {
        forceSSL = true;
        useACMEHost = "web";
        locations."/" = {
          proxyPass = "http://loki";
          proxyWebsockets = true;
          extraConfig = ''
            auth_basic "Authentication required";
            auth_basic_user_file ${config.age.secrets.loki-basic-auth-hashes.path};

            proxy_read_timeout 1800s;
            proxy_connect_timeout 1600s;

            access_log off;
          '';
        };
        locations."= /ready" = {
          proxyPass = "http://loki";
          extraConfig = ''
            auth_basic off;
            access_log off;
          '';
        };
      };
      virtualHosts.${globals.services.fireflypico.domain}.locations."/api" = {
        proxyPass = "http://fireflypico";
        proxyWebsockets = true;
        X-Frame-Options = "SAMEORIGIN";
        extraConfig = ''
          proxy_set_header X-User  "";
          proxy_set_header X-Email "";
        '';
      };
      virtualHosts.${globals.services.firefly.domain}.locations."/api" = {
        proxyPass = "http://firefly";
        proxyWebsockets = true;
        X-Frame-Options = "SAMEORIGIN";
        extraConfig = ''
          add_header Access-Control-Allow-Origin "https://pico.lel.lol" ;
          add_header Access-Control-Allow-Methods 'GET, POST, HEAD, OPTIONS';
          proxy_set_header X-User  "";
          proxy_set_header X-Email "";
        '';
      };
    }
    (blockOf "vaultwarden" { maxBodySize = "1G"; })
    (blockOf "jellyfin" {
      maxBodySize = "10G";
      port = 8096;
      virtualHostExtraConfig = ''
        allow ${globals.net.vlans.home.cidrv4} ;
        allow ${globals.net.vlans.home.cidrv6} ;
        deny all ;
      '';
    })
    (blockOf "forgejo" { maxBodySize = "1G"; })
    (blockOf "immich" {
      maxBodySize = "5G";
      virtualHostExtraConfig = ''
        proxy_buffering off;
        proxy_request_buffering off;
      '';
    })
    (proxyProtect "adguardhome" { })
    (proxyProtect "oauth2-proxy" {
      port = 3001;
      allowedGroup = false;
    })
    (lib.recursiveUpdate (blockOf "paperless" { maxBodySize = "5G"; }) {
      # Paperless allowed hosts disallows ip based access
      # django.core.exceptions.DisallowedHost: Invalid HTTP_HOST header: '10.42.0.10:3000'. You may need to add '10.42.0.10' to ALLOWED_HOSTS.
      upstreams."paperless".monitoring.enable = false;
    })
    (proxyProtect "ttrss" { port = 80; })
    (proxyProtect "invidious" { })
    (blockOf "yourspotify" { port = 80; })
    (blockOf "blog" { port = 80; })
    (blockOf "headscale" { })
    (blockOf "homeassistant" { })
    #(proxyProtect "ollama" { })
    (proxyProtect "esphome" { port = 3001; })
    (proxyProtect "firefly" { port = 80; })
    (proxyProtect "fireflypico" { port = 80; })
    (blockOf "grafana" { })
    (blockOf "apispotify" {
      port = 3000;
      upstream = "yourspotify";
    })
    (blockOf "nextcloud" {
      maxBodySize = "5G";
      port = 80;
    })
    (blockOf "kanidm" {
      protocol = "https";
      virtualHostExtraConfig = ''
        proxy_ssl_verify off ;
      '';
    })
  ];

  age.secrets.cloudflare_token_acme = {
    rekeyFile = config.node.secretsDir + "/cloudflare_api_token.age";
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
  security.acme.certs.web = {
    domain = globals.domains.web;
    extraDomainNames = [ "*.${globals.domains.web}" ];
  };
  users.groups.acme.members = [ "nginx" ];
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/acme";
      user = "acme";
      group = "acme";
      mode = "0755";
    }
  ];

  services.netbird.server.proxy =
    let
      cfg = nodes.nucnix-netbird.config.services.netbird.server;
    in
    {
      domain = "${globals.services.netbird.domain}";
      enableNginx = true;
      signalAddress = "${ipOf "netbird"}:${toString cfg.signal.port}";
      relayAddress = "${ipOf "netbird"}:${toString cfg.relay.port}";
      managementAddress = "${ipOf "netbird"}:${toString cfg.management.port}";
      dashboardAddress = "${ipOf "netbird"}:80";
    };
}
