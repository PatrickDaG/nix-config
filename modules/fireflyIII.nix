{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.services.firefly-iii;
  inherit
    (lib)
    mkIf
    types
    mkEnableOption
    mkOption
    mkPackageOption
    mapAttrs
    mkDefault
    ;

  package = cfg.package.override {
    dataDir = cfg.dataDir;
  };
in {
  options.services.firefly-iii = {
    enable = mkEnableOption "firefly-iii";
    dataDir = mkOption {
      description = "The firefly-iii data directory.";
      default = "/var/lib/firefly-iii";
      type = types.path;
    };
    package =
      mkPackageOption pkgs "firefly-iii" {
      };
    phpPackage = mkPackageOption pkgs "php" {
      example = "php82";
      default = "php83";
    };
    database = mkOption {
      description = "Which database to use";
      default = "sqlite";
      type = types.enum ["sqlite" "mysql" "pgsql"];
    };
    dbCreateLocally = mkOption {
      type = types.bool;
      default = false;
      description = "Create the database locally.";
    };
    virtualHost = mkOption {
      description = "The nginx virtualHost under which firefly-iii will be reachable";
      type = types.str;
    };
    settings = mkOption {
      type = with types; attrsOf (nullOr (oneOf [str path package]));
      description = ''
        The environment used by firefly-iii while running.
        See [example](https://github.com/firefly-iii/firefly-iii/blob/main/.env.example) for value definitions.
      '';
      default = {
        LOG_CHANNEL = "syslog";
      };
      example = {
        ALLOW_WEBHOOKS = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.firefly-iii.settings = {
      DB_CONNECTION = cfg.database;
    };

    assertions = [
      {
        assertion = cfg.dbCreateLocally -> cfg.database == "sqlite";
        message = "services.firefly-iii.dbCreateLocally is currently only supported for sqlite.";
      }
    ];

    services.phpfpm = {
      settings = {
        error_log = "syslog";
        log_level = "debug";
      };
      pools.firefly-iii = {
        phpOptions = ''
          log_errors = yes
          error_reporting = E_ALL
        '';
        user = "firefly-iii";
        group = "firefly-iii";
        phpPackage = cfg.phpPackage;
        phpEnv = cfg.settings;
        settings = mapAttrs (_: mkDefault) {
          catch_workers_output = "yes";
          "listen.mode" = "0660";
          "listen.owner" = config.services.nginx.user;
          "listen.group" = config.services.nginx.group;
          "pm" = "dynamic";
          "pm.max_children" = "32";
          "pm.start_servers" = "2";
          "pm.min_spare_servers" = "2";
          "pm.max_spare_servers" = "4";
          "pm.max_requests" = "500";
        };
      };
    };

    users.users.firefly-iii = {
      group = "firefly-iii";
      isSystemUser = true;
    };
    users.groups.firefly-iii.members = ["firefly-iii" config.services.nginx.user];
    systemd.services.firefly-iii-setup = {
      environment = cfg.settings;
      description = "Preparation tasks for Firefly III";
      before = ["phpfpm-firefly-iii.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "firefly-iii";
        WorkingDirectory = package;
      };
      script = ''
        set -euo pipefail
        umask 077
        ${lib.optionalString cfg.dbCreateLocally ''
          mkdir -p ${cfg.dataDir}/storage/database/
          touch ${cfg.dataDir}/storage/database/database.sqlite
        ''}

        # migrate db
        ${lib.getExe cfg.phpPackage} artisan migrate --force
        ${lib.getExe cfg.phpPackage} artisan firefly-iii:upgrade-database
        ${lib.getExe cfg.phpPackage} artisan firefly-iii:correct-database
        ${lib.getExe cfg.phpPackage} artisan firefly-iii:report-integrity
        ${lib.getExe cfg.phpPackage} artisan firefly-iii:laravel-passport-keys
      '';
    };

    # Data dir
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}                            0710 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage                    0700 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage/app                0700 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage/database           0700 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage/export             0700 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage/framework          0700 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage/framework/cache    0700 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage/framework/sessions 0700 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage/framework/views    0700 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage/logs               0700 firefly-iii firefly-iii - -"
      "d ${cfg.dataDir}/storage/upload             0700 firefly-iii firefly-iii - -"
    ];

    services.nginx = {
      enable = mkDefault true;
      recommendedSetup = true;
      recommendedTlsSettings = mkDefault true;
      recommendedOptimisation = mkDefault true;
      recommendedGzipSettings = mkDefault true;
      virtualHosts.${cfg.virtualHost} = {
        root = "${package}/public";
        locations = {
          "/" = {
            index = "index.php";
            tryFiles = "$uri $uri/ /index.php?$query_string";
            extraConfig = ''
              autoindex on;
              sendfile off;
            '';
          };
          "~* \\.php(?:$|/)" = {
            extraConfig = ''
              include ${config.services.nginx.package}/conf/fastcgi_params ;
              fastcgi_param SCRIPT_FILENAME $request_filename;
              fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
              fastcgi_pass unix:${config.services.phpfpm.pools.firefly-iii.socket};
            '';
          };
        };
      };
    };
  };
}
