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
    mkDefault
    mkIf
    ;
  cfg = config.services.netbird;

  configFile = formatType.generate config.json cfg.settings;

  formatType = pkgs.format.json {};
in {
  options.services.netbird = {
    enable = mkEnableOption "netbird, a self hosted wireguard VPN";
    domain = mkOption {
      description = "The domain of your netbird instance";
    };
    oidcConfigEndpoint = mkOption {
      type = types.str;
      example = "https://example.eu.auth0.com/.well-known/openid-configuration";
      description = "The oidc discovery endpoint";
    };
    dataDir = mkOption {
      description = "Runtime directory where netbird stores its data";
      types = types.path;
      default = /var/lib/netbird;
    };
    turn = {
      domain = mkOption {
        description = "The domain under which the TURN server is reachable";
        type = types.str;
        example = "localhost";
      };
      port = mkOption {
        description = "The port under which the TURN server is reachable";
        type = types.int;
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
      type = types.submodule {
        freeformType = formatType.type;
        options = {
        };
        config = mkDefault {
          Stuns = [
            {
              Proto = "udp";
              Uri = "stun:${cfg.turn.domain}:${cfg.turn.domain}";
              Username = "";
              Password = null;
            }
          ];
          TURNConfig = {
            Turns = [
              {
                Proto = "udp";
                Uri = "stun:${cfg.turn.domain}:${cfg.turn.port}";
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
          Datadir = cfg.dataDir;
          DataStoreEncryptionKey = lib.trace "uppsi wuppsi ich hab mein netbird unsiccccccher gemacht" "$NETBIRD_DATASTORE_ENC_KEY";
          StoreConfig = {
            Engine = "sqlite";
          };
          HttpConfig = {
            Address = "0.0.0.0:3000";
            #"AuthIssuer" = "$NETBIRD_AUTH_AUTHORITY";
            #"AuthAudience" = "$NETBIRD_AUTH_AUDIENCE";
            #"AuthKeysLocation" = "$NETBIRD_AUTH_JWT_CERTS";
            AuthUserIDClaim = "sub";
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
          #DeviceAuthorizationFlow = {
          #  Provider = "$NETBIRD_AUTH_DEVICE_AUTH_PROVIDER";
          #  "ProviderConfig" = {
          #    "Audience" = "$NETBIRD_AUTH_DEVICE_AUTH_AUDIENCE";
          #    "AuthorizationEndpoint" = "";
          #    "Domain" = "$NETBIRD_AUTH0_DOMAIN";
          #    "ClientID" = "$NETBIRD_AUTH_DEVICE_AUTH_CLIENT_ID";
          #    "ClientSecret" = "";
          #    "TokenEndpoint" = "$NETBIRD_AUTH_TOKEN_ENDPOINT";
          #    "DeviceAuthEndpoint" = "$NETBIRD_AUTH_DEVICE_AUTH_ENDPOINT";
          #    "Scope" = "$NETBIRD_AUTH_DEVICE_AUTH_SCOPE";
          #    "UseIDToken" = "$NETBIRD_AUTH_DEVICE_AUTH_USE_ID_TOKEN";
          #    "RedirectURLs" = null;
          #  };
          #};
          PKCEAuthorizationFlow = {
            ProviderConfig = {
              #Audience = "$NETBIRD_AUTH_PKCE_AUDIENCE";
              ClientID = "netbird";
              ClientSecret = lib.trace "oho bei zo vielen sicherheitzlücken" "$NETBIRD_AUTH_CLIENT_SECRET";
              Domain = "";
              #AuthorizationEndpoint = "$NETBIRD_AUTH_PKCE_AUTHORIZATION_ENDPOINT";
              #TokenEndpoint = "$NETBIRD_AUTH_TOKEN_ENDPOINT";
              Scope = "openid profile email";
              RedirectURLs = ["localhost:53000"];
              UseIDToken = "$NETBIRD_AUTH_PKCE_USE_ID_TOKEN";
            };
          };
        };
      };
    };
  };
  config =
    mkIf cfg.enable {
      systemd.services = {
        netbird-setup = {
          wantedBy = [
            "netbird-management.service"
            "netbird-signal.service"
            "multi-user.target"
          ];
          serviceConfig = {
            Type = "oneshot";
            RuntimeDirectory = "netbird-mgmt";
            StateDirectory = "netbird-mgmt";
            WorkingDirectory = cfg.dataDir;
            EnvironmentFile = [  ];
          };
          unitConfig = {
            StartLimitInterval = 5;
            StartLimitBurst = 10;
          };

          path =
            [
              pkgs.coreutils
              pkgs.findutils
              pkgs.gettext
              pkgs.gnused
           # ]
           # ++ (optionals cfg.setupAutoOidc [
           #   pkgs.curl
           #   pkgs.jq
            ];

          script =
            ''
              cp ${configFile} ${cfg.dataDir}/management.json
            ''
            #+ (optionalString cfg.setupAutoOidc ''
            #  mv ${stateDir}/management.json.copy ${stateDir}/management.json
            #  echo "loading OpenID configuration from $NETBIRD_AUTH_OIDC_CONFIGURATION_ENDPOINT to the openid-configuration.json file"
            #  curl "$NETBIRD_AUTH_OIDC_CONFIGURATION_ENDPOINT" -q -o ${stateDir}/openid-configuration.json

            #  export NETBIRD_AUTH_AUTHORITY=$(jq -r '.issuer' ${stateDir}/openid-configuration.json)
            #  export NETBIRD_AUTH_JWT_CERTS=$(jq -r '.jwks_uri' ${stateDir}/openid-configuration.json)
            #  export NETBIRD_AUTH_TOKEN_ENDPOINT=$(jq -r '.token_endpoint' ${stateDir}/openid-configuration.json)
            #  export NETBIRD_AUTH_DEVICE_AUTH_ENDPOINT=$(jq -r '.device_authorization_endpoint' ${stateDir}/openid-configuration.json)
            #  export NETBIRD_AUTH_PKCE_AUTHORIZATION_ENDPOINT=$(jq -r '.authorization_endpoint' ${stateDir}/openid-configuration.json)

            #  envsubst '$NETBIRD_AUTH_AUTHORITY $NETBIRD_AUTH_JWT_CERTS $NETBIRD_AUTH_TOKEN_ENDPOINT $NETBIRD_AUTH_DEVICE_AUTH_ENDPOINT $NETBIRD_AUTH_PKCE_AUTHORIZATION_ENDPOINT' < ${stateDir}/management.json > ${stateDir}/management.json.copy
            #'')
            #+ ''
           #   # Update secrets in management.json
           #   ${builtins.concatStringsSep "\n" (
           #     builtins.attrValues (
           #       builtins.mapAttrs (name: path: "export ${name}=$(cat ${path})") (
           #         filterAttrs (_: p: p != null) cfg.secretFiles
           #       )
           #     )
           #   )}
            + ''

              #envsubst '$TURN_PASSWORD $TURN_SECRET $STUN_PASSWORD $AUTH_CLIENT_SECRET $IDP_MGMT_CLIENT_SECRET' < ${cfg.dataDir}/management.json.copy > ${cfg.dataDir}/management.json

              rm -rf ${cfg.dataDir}/web-ui
              mkdir -p ${cfg.dataDir}/web-ui
              cp -R ${cfg.dashboard}/* ${cfg.dataDir}/web-ui

              export AUTH_AUTHORITY="$NETBIRD_AUTH_AUTHORITY"
              export AUTH_CLIENT_ID="$NETBIRD_AUTH_CLIENT_ID"
              ${optionalString (cfg.secretFiles.AUTH_CLIENT_SECRET == null)
                ''export AUTH_CLIENT_SECRET="$NETBIRD_AUTH_CLIENT_SECRET"''}
              export AUTH_AUDIENCE="$NETBIRD_AUTH_AUDIENCE"
              export AUTH_REDIRECT_URI="$NETBIRD_AUTH_REDIRECT_URI"
              export AUTH_SILENT_REDIRECT_URI="$NETBIRD_AUTH_SILENT_REDIRECT_URI"
              export USE_AUTH0="$NETBIRD_USE_AUTH0"
              export AUTH_SUPPORTED_SCOPES=$(echo $NETBIRD_AUTH_SUPPORTED_SCOPES | sed -E 's/"//g')

              export NETBIRD_MGMT_API_ENDPOINT=$(echo $NETBIRD_MGMT_API_ENDPOINT | sed -E 's/(:80|:443)$//')

              MAIN_JS=$(find ${cfg.dataDir}/web-ui/static/js/main.*js)
              OIDC_TRUSTED_DOMAINS=${cfg.dataDir}/web-ui/OidcTrustedDomains.js
              mv "$MAIN_JS" "$MAIN_JS".copy
              envsubst '$USE_AUTH0 $AUTH_AUTHORITY $AUTH_CLIENT_ID $AUTH_CLIENT_SECRET $AUTH_SUPPORTED_SCOPES $AUTH_AUDIENCE $NETBIRD_MGMT_API_ENDPOINT $NETBIRD_MGMT_GRPC_API_ENDPOINT $NETBIRD_HOTJAR_TRACK_ID $AUTH_REDIRECT_URI $AUTH_SILENT_REDIRECT_URI $NETBIRD_TOKEN_SOURCE $NETBIRD_DRAG_QUERY_PARAMS' < "$MAIN_JS".copy > "$MAIN_JS"
              envsubst '$NETBIRD_MGMT_API_ENDPOINT' < "$OIDC_TRUSTED_DOMAINS".tmpl > "$OIDC_TRUSTED_DOMAINS"
            '';
        };

        netbird-signal = {
          after = [ "network.target" ];
          wantedBy = [ "netbird-management.service" ];
          restartTriggers = [
            settingsFile
            managementFile
          ];

          serviceConfig = {
            ExecStart = ''
              ${cfg.package}/bin/netbird-signal run \
                --port ${builtins.toString cfg.ports.signal} \
                --log-file console \
                --log-level ${cfg.logLevel}
            '';
            Restart = "always";
            RuntimeDirectory = "netbird-mgmt";
            StateDirectory = "netbird-mgmt";
            WorkingDirectory = cfg.dataDir;
          };
          unitConfig = {
            StartLimitInterval = 5;
            StartLimitBurst = 10;
          };
          stopIfChanged = false;
        };

        netbird-management = {
          description = "The management server for Netbird, a wireguard VPN";
          documentation = [ "https://netbird.io/docs/" ];
          after = [
            "network.target"
            "netbird-setup.service"
          ];
          wantedBy = [ "multi-user.target" ];
          wants = [
            "netbird-signal.service"
            "netbird-setup.service"
          ];
          restartTriggers = [
            settingsFile
            managementFile
          ];

          serviceConfig = {
            ExecStart = ''
              ${cfg.package}/bin/netbird-mgmt management \
                --config ${stateDir}/management.json \
                --datadir ${stateDir}/data \
                ${optionalString cfg.management.disableAnonymousMetrics "--disable-anonymous-metrics"} \
                ${optionalString cfg.management.disableSingleAccountMode "--disable-single-account-mode"} \
                --dns-domain ${cfg.management.dnsDomain} \
                --single-account-mode-domain ${cfg.management.singleAccountModeDomain} \
                --idp-sign-key-refresh-enabled \
                --port ${builtins.toString cfg.ports.management} \
                --log-file console \
                --log-level ${cfg.logLevel}
            '';
            Restart = "always";
            RuntimeDirectory = "netbird-mgmt";
            StateDirectory = [
              "netbird-mgmt"
              "netbird-mgmt/data"
            ];
            WorkingDirectory = stateDir;
          };
          unitConfig = {
            StartLimitInterval = 5;
            StartLimitBurst = 10;
          };
          stopIfChanged = false;
        };
      };
    })
    };
}
