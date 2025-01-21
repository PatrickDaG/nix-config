{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkPackageOption
    mkOption
    mkIf
    getExe
    mkEnableOption
    ;
in
{
  options.services.firezone = {
    server = {
      enable = mkEnableOption "the gui client and corresponding ipc service for firezone.";
      domain = {
        enable = mkEnableOption "the firezone ";
        package = mkPackageOption pkgs "firezone-server-domain" { };
        enableLocalDB = mkEnableOption "a local postgresql database for firezone";
      };
    };
  };
  config =
    let
      cfg = config.services.firezone.server;
    in
    mkIf cfg.enable {
      services.postgresql = {
        enable = true;
        ensureUsers = [
          {
            name = "firezone";
            ensureDBOwnership = true;
          }
        ];
        ensureDatabases = [ "firezone" ];
      };
      systemd.services.firezone-server-domain = {
        description = "Firezone Domain server";
        after = mkIf cfg.domain.enableLocalDB "postergsql.service";
        wants = mkIf cfg.domain.enableLocalDB "postergsql.service";

        serviceConfig = {

          AmbientCapabilities = "CAP_NET_ADMIN";
          CapabilityBoundingSet = "CAP_CHOWN CAP_NET_ADMIN";
          DeviceAllow = "/dev/net/tun";
          LockPersonality = "true";
          LogsDirectory = "dev.firezone.client";
          LogsDirectoryMode = "755";
          MemoryDenyWriteExecute = "true";
          NoNewPrivileges = "true";
          PrivateMounts = "true";
          PrivateTmp = "true";
          PrivateUsers = "false";
          ProcSubset = "pid";
          ProtectClock = "true";
          ProtectControlGroups = "true";
          ProtectHome = "true";
          ProtectHostname = "true";
          ProtectKernelLogs = "true";
          ProtectKernelModules = "true";
          ProtectKernelTunables = "true";
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
            "AF_UNIX"
          ];
          RestrictNamespaces = "true";
          RestrictRealtime = "true";
          RestrictSUIDSGID = "true";
          RuntimeDirectory = "dev.firezone.client";
          StateDirectory = "dev.firezone.client";
          SystemCallArchitectures = "native";
          SystemCallFilter = "@aio @basic-io @file-system @io-event @ipc @network-io @signal @system-service";
          UMask = "077";

          ExecStart = ''
            ${getExe cfg.domain.package} start
          '';

          Type = "notify";
          # Unfortunately we need root to control DNS
          User = "firezone";
          Group = "firezone";
          Environment = {
            # Erlang;
            ERLANG_DISTRIBUTION_PORT = 9000;
            ERLANG_CLUSTER_ADAPTER = "Elixir.Cluster.Strategy.Epmd";
            ERLANG_CLUSTER_ADAPTER_CONFIG = '''{"hosts":["api@api.cluster.local","web@web.cluster.local","domain@domain.cluster.local"]}' '';
            RELEASE_COOKIE = "NksuBhJFBhjHD1uUa9mDOHV";
            RELEASE_HOSTNAME = "domain.cluster.local";
            RELEASE_NAME = "domain";
            # Database;
            DATABASE_HOST = "localhost";
            DATABASE_PORT = "/run/postgersql";
            DATABASE_NAME = "firezone";
            DATABASE_USER = "firezone";
            DATABASE_PASSWORD = "";
            # Auth;
            AUTH_PROVIDER_ADAPTERS = "email,openid_connect,userpass,token,google_workspace,microsoft_entra,okta,jumpcloud";
            # Secrets;
            TOKENS_KEY_BASE = "5OVYJ83AcoQcPmdKNksuBhJFBhjHD1uUa9mDOHV/6EIdBQ6pXksIhkVeWIzFk5S2";
            TOKENS_SALT = "t01wa0K4lUd7mKa0HAtZdE+jFOPDDej2";
            SECRET_KEY_BASE = "5OVYJ83AcoQcPmdKNksuBhJFBhjHD1uUa9mDOHV/6EIdBQ6pXksIhkVeWIzFk5S2";
            LIVE_VIEW_SIGNING_SALT = "t01wa0K4lUd7mKa0HAtZdE+jFOPDDej2";
            COOKIE_SIGNING_SALT = "t01wa0K4lUd7mKa0HAtZdE+jFOPDDej2";
            COOKIE_ENCRYPTION_SALT = "t01wa0K4lUd7mKa0HAtZdE+jFOPDDej2";
            # Debugging;
            LOG_LEVEL = "debug";
            # Emails;
            OUTBOUND_EMAIL_FROM = "public-noreply@firez.one";
            OUTBOUND_EMAIL_ADAPTER = "Elixir.Swoosh.Adapters.Postmark";
            ## Warning= The token is for the blackhole Postmark server created in a separate isolated account,;
            ## that WILL NOT send any actual emails, but you can see and debug them in the Postmark dashboard.;
            OUTBOUND_EMAIL_ADAPTER_OPTS = '''{"api_key":"7da7d1cd-111c-44a7-b5ac-4027b9d230e5"}' '';
            # Seeds;
            STATIC_SEEDS = "true";
            # Feature flags;
            FEATURE_FLOW_ACTIVITIES_ENABLED = "true";
            FEATURE_POLICY_CONDITIONS_ENABLED = "true";
            FEATURE_MULTI_SITE_RESOURCES_ENABLED = "true";
            FEATURE_SELF_HOSTED_RELAYS_ENABLED = "true";
            FEATURE_IDP_SYNC_ENABLED = "true";
            FEATURE_REST_API_ENABLED = "true";
            FEATURE_INTERNET_RESOURCE_ENABLED = "true";
          };
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

}
