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
    enableCoturn = mkEnableOption "the coturn service for running the TURN/STUN server";
    domain = mkOption {
      type = types.str;
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
      description = ''
        This will be converted to json and used as the management config.
        Sadly the exact configuration is undocumented there only exists
        this [template](https://github.com/netbirdio/netbird/blob/main/infrastructure_files/management.json.tmpl)
        The default values are usable, for a normal setup you don't need to set anything here.
        Be advised that any secret you set in here will be in the nix store
        and thus world readable. For compliant setups you don't need these secrets
        as you should use a oidc public client, some client, e.g. google do not support
        this without a secret, which is why you sometimes need to set a secret here.
        This is not a problem as this secret will be exposed on your server publicly and only allows
        client to initiate a authorization flow.
        Even though the template contains oidc values you don't need to set any except for the
        ConfigEndpoint as netbird will fetch the rest.
      '';
      type = types.submodule {
        freeformType = formatType.type;
        config = {
          Stuns = [
            {
              Proto = "udp";
              Uri = "stun:${cfg.turn.domain}:${toString cfg.turn.port}";
              # TODO fairly certain with this config anyone can use your STUN server
              Username = "";
              Password = null;
            }
          ];
          TURNConfig = {
            Turns = [
              {
                Proto = "udp";
                Uri = "turn:${cfg.turn.domain}:${toString cfg.turn.port}";
                Username = cfg.turn.userName;
                Password = cfg.turn.password;
              }
            ];
            CredentialsTTL = "12h";
            # This is not used with the standard coturn configuration
            Secret = "secret";
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
            AuthUserIDClaim = "preferred_username";
            OIDCConfigEndpoint = cfg.oidcConfigEndpoint;
          };
          IdpManagerConfig = {
            ManagerType = "none";
          };
          DeviceAuthorizationFlow = {
            ProviderConfig = {
              Audience = "netbird";
              Scope = "openid profile email";
            };
          };
          PKCEAuthorizationFlow = {
            ProviderConfig = {
              Audience = "netbird";
              ClientID = "netbird";
              ClientSecret = "";
              Domain = "";
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
    services.coturn = mkIf cfg.enableCoturn {
      enable = true;

      realm = cfg.dorain;
      lt-cred-mech = true;
      no-cli = true;

      # Official documentation says that external-ip has to be
      # an IP which is not true as [this](https://github.com/coturn/coturn/blob/9b1cca1fbe909e7cc7c7ac28865f9c190af3515b/src/client/ns_turn_ioaddr.c#L234)
      # will resolve a dns name as well
      extraConfig = ''
        fingerprint

        user=${cfg.turn.userName}:${cfg.turn.password}
        no-software-attribute
        external-ip=${cfg.domain}
      '';
    };
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
          RestartSec = "60";

          # hardening
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = true;
          RemoveIPC = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;

          # Hardening
          CapabilityBoundingSet = "";
          PrivateUsers = true;
          ProtectProc = "invisible";
          ProcSubset = "pid";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "@pkey"
          ];
          UMask = "0077";
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
          # Should we automatically disable metrics?
          ExecStart = ''
            ${cfg.package}/bin/netbird-mgmt management \
              --config ${configFile} \
              --datadir /var/lib/netbird-mgmt/data \
              --disable-anonymous-metrics=true \
              ${
              if cfg.singleAccountModeDomain == null
              then "--disable-single-account-mode"
              else "--single-account-mode-domain ${cfg.singleAccountModeDomain}"
            } \
              --idp-sign-key-refresh-enabled \
              --port ${builtins.toString cfg.port} \
              --log-file console
          '';
          # TODO add extraCommandLine option
          Restart = "always";
          RuntimeDirectory = "netbird-mgmt";
          StateDirectory = [
            "netbird-mgmt"
            "netbird-mgmt/data"
          ];
          WorkingDirectory = "/var/lib/netbird-mgmt";

          # hardening
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = true;
          RemoveIPC = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;

          # Hardening
          CapabilityBoundingSet = "";
          PrivateUsers = true;
          ProtectProc = "invisible";
          ProcSubset = "pid";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "@pkey"
          ];
          UMask = "0077";
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
