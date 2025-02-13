{
  config,
  ...
}:
{
  networking.nftables.firewall.rules.ingress = {
    from = [
      "wg-monitoring"
    ];
    to = [ "local" ];
    allowedTCPPorts = [ config.services.loki.configuration.server.http_listen_port ];
  };

  globals.services.loki.host = config.node.name;
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [
      config.services.loki.configuration.server.http_listen_port
    ];
  };

  age.secrets.loki-basic-auth-hashes = {
    generator.script = "basic-auth";
    mode = "440";
    intermediary = true;
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/loki";
      user = "loki";
      group = "loki";
      mode = "0700";
    }
  ];

  services.loki =
    let
      lokiDir = "/var/lib/loki";
    in
    {
      enable = true;
      configuration = {
        analytics.reporting_enabled = false;
        auth_enabled = false;

        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = 3100;
          log_level = "warn";
        };

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore.store = "inmemory";
              replication_factor = 1;
            };
            final_sleep = "0s";
          };
          chunk_idle_period = "5m";
          chunk_retain_period = "30s";
        };

        schema_config.configs = [
          {
            from = "2023-06-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "${lokiDir}/tsdb-index";
            cache_location = "${lokiDir}/tsdb-cache";
            cache_ttl = "24h";
          };
          filesystem.directory = "${lokiDir}/chunks";
        };

        # Do not accept new logs that are ingressed when they are actually already old.
        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
          allow_structured_metadata = false;
        };

        # Do not delete old logs automatically
        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };

        compactor = {
          working_directory = lokiDir;
          compactor_ring.kvstore.store = "inmemory";
        };
      };
    };

  systemd.services.loki.serviceConfig.RestartSec = "60"; # Retry every minute
}
