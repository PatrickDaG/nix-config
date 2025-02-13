{
  config,
  globals,
  lib,
  nodes,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatLists
    elem
    flip
    forEach
    mkForce
    mapAttrsToList
    mkAfter
    mkIf
    optional
    optionalAttrs
    optionals
    toList
    mkOption
    types
    ;

  mkIfNotEmpty = xs: mkIf (xs != [ ]) xs;
  cfg = config.meta.telegraf;
in
{
  options.meta.telegraf = {
    availableMonitoringNetworks = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = {
    # Monitor anything that can only be monitored from this node
    meta.telegraf.availableMonitoringNetworks = [
      "local-${config.node.name}"
    ] ++ (lib.optional (config.node.type == "host") "internet");

    nodes.${globals.services.influxdb.host} = {
      # Mirror the original secret on the influx host
      age.secrets."telegraf-influxdb-token-${config.node.name}" = {
        inherit (config.age.secrets.telegraf-influxdb-token) rekeyFile;
        mode = "440";
        group = "influxdb2";
      };

      services.influxdb2.provision.organizations.machines.auths."telegraf (${config.node.name})" = {
        readBuckets = [ "telegraf" ];
        writeBuckets = [ "telegraf" ];
        tokenFile =
          nodes.${globals.services.influxdb.host}.config.age.secrets."telegraf-influxdb-token-${config.node.name}".path;
      };
    };

    age.secrets.telegraf-influxdb-token = {
      generator.script = "alnum";
      mode = "440";
      group = "telegraf";
    };

    security.elewrap.telegraf-sensors = mkIf (config.node.type == "host") {
      command = [
        "${pkgs.lm_sensors}/bin/sensors"
        "-A"
        "-u"
      ];
      targetUser = "root";
      allowedUsers = [ "telegraf" ];
    };

    security.elewrap.telegraf-nvme = mkIf config.services.smartd.enable {
      command = [ "${pkgs.nvme-cli}/bin/nvme" ];
      targetUser = "root";
      allowedUsers = [ "telegraf" ];
      passArguments = true;
    };

    security.elewrap.telegraf-smartctl = mkIf config.services.smartd.enable {
      command = [ "${pkgs.smartmontools}/bin/smartctl" ];
      targetUser = "root";
      allowedUsers = [ "telegraf" ];
      passArguments = true;
    };

    services.telegraf = {
      enable = true;
      environmentFiles = [ "/dev/null" ]; # Needed so the config file is copied to /run/telegraf
      extraConfig = {
        agent = {
          interval = "10s";
          round_interval = true; # Always collect on :00,:10,...
          metric_batch_size = 5000;
          metric_buffer_limit = 50000;
          collection_jitter = "0s";
          flush_interval = "20s";
          flush_jitter = "5s";
          precision = "1ms";
          hostname = config.node.name;
          omit_hostname = false;
        };
        outputs = {
          influxdb_v2 = {
            urls = [
              "http://${globals.wireguard.monitoring.hosts.${globals.services.influxdb.host}.ipv4}:8086"
            ];
            token = "@INFLUX_TOKEN@";
            organization = "machines";
            bucket = "telegraf";
          };
        };
        inputs =
          {
            conntrack = { };
            cpu = { };
            disk = { };
            diskio = mkIf (!config.boot.isContainer) { };
            internal = { };
            interrupts = { };
            kernel = { };
            kernel_vmstat = { };
            linux_sysctl_fs = { };
            mem = { };
            net = {
              ignore_protocol_stats = true;
            };
            netstat = { };
            nstat = { };
            processes = { };
            swap = { };
            system = { };
            systemd_units = {
              unittype = "service";
            };
            temp = mkIf (config.node.type == "host") { };
            wireguard = { };

            ping = mkIfNotEmpty (
              concatLists (
                flip mapAttrsToList globals.monitoring.ping (
                  name: pingCfg:
                  optionals (elem pingCfg.network cfg.availableMonitoringNetworks) (
                    concatLists (
                      forEach
                        [
                          "hostv4"
                          "hostv6"
                        ]
                        (
                          attr:
                          optional (pingCfg.${attr} != null) {
                            interval = "1m";
                            method = "native";
                            urls = [ pingCfg.${attr} ];
                            ipv4 = attr == "hostv4";
                            ipv6 = attr == "hostv6";
                            tags = {
                              inherit name;
                              inherit (pingCfg) network;
                              ip_version = if attr == "hostv4" then "v4" else "v6";
                            };
                            fieldinclude = [
                              "percent_packet_loss"
                              "average_response_ms"
                            ];
                          }
                        )
                    )
                  )
                )
              )
            );

            http_response = mkIfNotEmpty (
              concatLists (
                flip mapAttrsToList globals.monitoring.http (
                  name: httpCfg:
                  optional (elem httpCfg.network cfg.availableMonitoringNetworks) {
                    interval = "1m";
                    urls = toList httpCfg.url;
                    method = "GET";
                    response_status_code = httpCfg.expectedStatus;
                    response_string_match = mkIf (httpCfg.expectedBodyRegex != null) httpCfg.expectedBodyRegex;
                    insecure_skip_verify = httpCfg.skipTlsVerification;
                    follow_redirects = true;
                    tags = {
                      inherit name;
                      inherit (httpCfg) network;
                    };
                  }
                )
              )
            );

            dns_query = mkIfNotEmpty (
              concatLists (
                flip mapAttrsToList globals.monitoring.dns (
                  name: dnsCfg:
                  optional (elem dnsCfg.network cfg.availableMonitoringNetworks) {
                    interval = "1m";
                    servers = [ dnsCfg.server ];
                    domains = [ dnsCfg.domain ];
                    record_type = dnsCfg.record-type;
                    tags = {
                      inherit name;
                      inherit (dnsCfg) network;
                    };
                  }
                )
              )
            );

            net_response = mkIfNotEmpty (
              concatLists (
                flip mapAttrsToList globals.monitoring.tcp (
                  name: tcpCfg:
                  optional (elem tcpCfg.network cfg.availableMonitoringNetworks) {
                    interval = "1m";
                    address = "${tcpCfg.host}:${toString tcpCfg.port}";
                    protocol = "tcp";
                    tags = {
                      inherit name;
                      inherit (tcpCfg) network;
                    };
                    fieldexclude = [
                      "result_type"
                      "string_found"
                    ];
                  }
                )
              )
            );
          }
          // optionalAttrs config.services.smartd.enable {
            sensors = { };
            smart = {
              attributes = true;
              path_nvme = config.security.elewrap.telegraf-nvme.path;
              path_smartctl = config.security.elewrap.telegraf-smartctl.path;
              use_sudo = false;
            };
          }
          // optionalAttrs config.services.nginx.enable {
            nginx.urls = [ "http://localhost/nginx_status" ];
          }
          // optionalAttrs (config.networking.wireless.enable || config.networking.wireless.iwd.enable) {
            wireless = { };
          };
      };
    };

    services.nginx.virtualHosts = mkIf config.services.nginx.enable {
      localhost.listenAddresses = [
        "127.0.0.1"
        "[::1]"
      ];
      localhost.locations."= /nginx_status".extraConfig = ''
        allow 127.0.0.0/8;
        allow ::1;
        deny all;
        stub_status;
        access_log off;
      '';
    };

    environment.persistence."/persist".directories = [
      {
        directory = "/var/lib/telegraf";
        user = "telegraf";
        group = "telegraf";
        mode = "0700";
      }
    ];

    systemd.services.telegraf = {
      path = [
        # Make sensors refer to the correct wrapper
        (mkIf (config.node.type == "host") (
          pkgs.writeShellScriptBin "sensors" config.security.elewrap.telegraf-sensors.path
        ))
      ];
      serviceConfig = {
        ExecStartPre = mkAfter [
          (pkgs.writeShellScript "pre-start-token" ''
            ${lib.getExe pkgs.replace-secret} \
              "@INFLUX_TOKEN@" \
              ${config.age.secrets.telegraf-influxdb-token.path} \
              /var/run/telegraf/config.toml
          '')
        ];
        # For wireguard statistics
        AmbientCapabilities = [ "CAP_NET_ADMIN" ];
        RestartSec = "60"; # Retry every minute
        ExecStart = mkForce (
          "${config.services.telegraf.package}/bin/telegraf -config /var/run/telegraf/config.toml"
          + (lib.optionalString config.boot.isContainer " --unprotected")
        );
      };
    };
  };
}
