{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    types
    mkPackageOption
    mkIf
    ;
  cfg = config.services.netbird-server;

  configFile = formatType.generate "config.json" cfg.settings;

  formatType = pkgs.formats.json {};
in {
  options.services.netbird-server = {
    enable = mkEnableOption "netbird, a self hosted wireguard VPN";
    package = mkPackageOption pkgs "netbird" {};
    domain = mkOption {
      description = "The domain of your netbird instance";
    };
    port = mkOption {
      description = "The port the management interface will listen on";
      type = types.port;
      default = 3000;
    };
    oidcConfigEndpoint = mkOption {
      type = types.str;
      example = "https://example.eu.auth0.com/.well-known/openid-configuration";
      description = "The oidc discovery endpoint";
    };
    signalPort = mkOption {
      description = "The listening port for the signal protocol";
      default = 3001;
      type = types.port;
    };

    singleAccountModeDomain = mkOption {
      description = "Optional domain for single account mode, set to null to disable singleAccountMode";
      type = types.nullOr types.str;
      default = "netbird.selfhosted";
      example = null;
    };

    turn = {
      domain = mkOption {
        description = "The domain under which the TURN server is reachable";
        type = types.str;
        example = "localhost";
        default = cfg.domain;
      };
      port = mkOption {
        description = "The port under which the TURN server is reachable";
        type = types.port;
        default = 3478;
      };
      userName = mkOption {
        description = "The Username for logging into your turn server";
        type = types.str;
        default = "netbird";
      };
      password = mkOption {
        description = "The password for logging into your turn server";
        type = types.str;
        default = lib.trace "should not be part of the final config" "netbird";
      };
    };
    settings = mkOption {
      default = {};
      type = types.submodule {
        freeformType = formatType.type;
        config = {
          Stuns = [
            {
              Proto = "udp";
              Uri = "turn:${cfg.turn.domain}:${toString cfg.turn.port}";
              Username = "";
              Password = null;
            }
          ];
          TURNConfig = {
            Turns = [
              {
                Proto = "udp";
                Uri = "stun:${cfg.turn.domain}:${toString cfg.turn.port}";
                Username = cfg.turn.userName;
                Password = cfg.turn.password;
              }
            ];
            CredentialsTTL = "12h";
            Secret = lib.trace "this should probably be an option as well" "secret";
            TimeBasedCredentials = false;
          };

          Signal = {
            Proto = "https";
            URI = "${cfg.domain}:443";
            Username = "";
            Password = null;
          };
          ReverseProxy = {
            TrustedHTTPProxies = [];
            TrustedHTTPProxiesCount = 0;
            TrustedPeers = [
              "0.0.0.0/0"
            ];
          };
          Datadir = "/var/lib/netbird-mgmt";
          DataStoreEncryptionKey = lib.trace "uppsi wuppsi ich hab mein netbird unsiccccccher gemacht" "X4/obyAolDVhjGsz8NDb4TJqgCfwmCA7lOtJFHt9L3w=";
          StoreConfig = {
            Engine = "sqlite";
          };
          HttpConfig = {
            Address = "0.0.0.0:${toString cfg.port}";
            AuthAudience = "netbird";
            #"AuthIssuer" = "$NETBIRD_AUTH_AUTHORITY";
            #"AuthAudience" = "$NETBIRD_AUTH_AUDIENCE";
            #"AuthKeysLocation" = "$NETBIRD_AUTH_JWT_CERTS";
            AuthUserIDClaim = "preferred_username";
            #"CertFile" = "$NETBIRD_MGMT_API_CERT_FILE";
            #"CertKey" = "$NETBIRD_MGMT_API_CERT_KEY_FILE";
            #"IdpSignKeyRefreshEnabled" = "$NETBIRD_MGMT_IDP_SIGNKEY_REFRESH";
            OIDCConfigEndpoint = cfg.oidcConfigEndpoint;
          };
          IdpManagerConfig = {
            ManagerType = "none";
            ClientConfig = {
              #"Issuer" = "$NETBIRD_AUTH_AUTHORITY";
              #TokenEndpoint = "$NETBIRD_AUTH_TOKEN_ENDPOINT";
              ClientID = "netbird-manager";
              ClientSecret = lib.trace "oho wer stiehlt meine zugäneg zuerts" "$NETBIRD_IDP_MGMT_CLIENT_SECRET";
              GrantType = "client_credentials";
            };
            #"ExtraConfig" = "$NETBIRD_IDP_MGMT_EXTRA_CONFIG";
            #"Auth0ClientCredentials" = null;
            #"AzureClientCredentials" = null;
            #"KeycloakClientCredentials" = null;
            #"ZitadelClientCredentials" = null;
          };
          DeviceAuthorizationFlow = {
            #Provider = "$NETBIRD_AUTH_DEVICE_AUTH_PROVIDER";
            ProviderConfig = {
              Audience = "netbird";
              #"AuthorizationEndpoint" = "";
              #"Domain" = "$NETBIRD_AUTH0_DOMAIN";
              #"ClientID" = "$NETBIRD_AUTH_DEVICE_AUTH_CLIENT_ID";
              #"ClientSecret" = "";
              #"TokenEndpoint" = "$NETBIRD_AUTH_TOKEN_ENDPOINT";
              #"DeviceAuthEndpoint" = "$NETBIRD_AUTH_DEVICE_AUTH_ENDPOINT";
              Scope = "openid profile email";
              #"UseIDToken" = "$NETBIRD_AUTH_DEVICE_AUTH_USE_ID_TOKEN";
              #"RedirectURLs" = null;
            };
          };
          PKCEAuthorizationFlow = {
            ProviderConfig = {
              Audience = "netbird";
              ClientID = "netbird";
              ClientSecret = lib.trace "oho bei zo vielen sicherheitzlücken" "";
              Domain = "";
              #AuthorizationEndpoint = "$NETBIRD_AUTH_PKCE_AUTHORIZATION_ENDPOINT";
              #TokenEndpoint = "$NETBIRD_AUTH_TOKEN_ENDPOINT";
              Scope = "openid profile email";
              RedirectURLs = ["http://localhost:53000"];
              UseIDToken = true;
            };
          };
        };
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services = {
      netbird-signal = {
        after = ["network.target"];
        wantedBy = ["netbird-management.service"];
        restartTriggers = [
          configFile
        ];

        serviceConfig = {
          ExecStart = ''
            ${cfg.package}/bin/netbird-signal run \
              --log-file console \
              --port ${builtins.toString cfg.signalPort}
          '';
          Restart = "always";
          RuntimeDirectory = "netbird-mgmt";
          StateDirectory = "netbird-mgmt";
          WorkingDirectory = "/var/lib/netbird-mgmt";
        };
        unitConfig = {
          StartLimitInterval = 5;
          StartLimitBurst = 10;
        };
        stopIfChanged = false;
      };

      netbird-management = {
        description = "The management server for Netbird, a wireguard VPN";
        documentation = ["https://netbird.io/docs/"];
        after = [
          "network.target"
          "netbird-setup.service"
        ];
        wantedBy = ["multi-user.target"];
        wants = [
          "netbird-signal.service"
          "netbird-setup.service"
        ];
        restartTriggers = [
          configFile
        ];

        serviceConfig = {
          ExecStart = ''
            ${cfg.package}/bin/netbird-mgmt management \
              --config ${configFile} \
              --datadir /var/lib/netbird-mgmt/data \
              --disable-anonymous-metrics \
              ${
              if cfg.singleAccountModeDomain == null
              then "--disable-single-account-mode"
              else "--single-account-mode-domain ${cfg.singleAccountModeDomain}"
            } \
              --idp-sign-key-refresh-enabled \
              --port ${builtins.toString cfg.port} \
              --log-file console
          '';
          # TODO add extraCOmmandLine option
          Restart = "always";
          RuntimeDirectory = "netbird-mgmt";
          StateDirectory = [
            "netbird-mgmt"
            "netbird-mgmt/data"
          ];
          WorkingDirectory = "/var/lib/netbird-mgmt";
        };
        unitConfig = {
          StartLimitInterval = 5;
          StartLimitBurst = 10;
        };
        stopIfChanged = false;
      };
    };
  };
}
