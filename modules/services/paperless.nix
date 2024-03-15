{
  pkgs,
  nodes,
  config,
  lib,
  ...
}: let
  paperlessdomain = "ppl.${config.secrets.secrets.global.domains.web}";
  paperlessBackupDir = "/var/cache/backups/paperless";
in {
  systemd.tmpfiles.settings = {
    "10-paperless".${paperlessBackupDir}.d = {
      inherit (config.services.paperless) user;
      mode = "0770";
    };
  };
  age.secrets.resticpasswd = {
    generator.script = "alnum";
  };
  age.secrets.paperlessHetznerSsh = {
    generator.script = "ssh-ed25519";
  };
  services.restic.backups = {
    main = {
      user = "root";
      timerConfig = {
        OnCalendar = "06:00";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
      initialize = true;
      passwordFile = config.age.secrets.resticpasswd.path;
      hetznerStorageBox = {
        enable = true;
        inherit (config.secrets.secrets.global.hetzner) mainUser;
        inherit (config.secrets.secrets.global.hetzner.users.paperless) subUid path;
        sshAgeSecret = "paperlessHetznerSsh";
      };
      paths = [paperlessBackupDir];
      pruneOpts = [
        "--keep-daily 10"
        "--keep-weekly 7"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
    };
  };
  systemd.services.paperless-backup = let
    cfg = config.systemd.services.paperless-consumer;
  in {
    description = "Paperless document backup";
    serviceConfig =
      lib.recursiveUpdate
      cfg.serviceConfig
      {
        ExecStart = "${config.services.paperless.package}/bin/paperless-ngx document_exporter -na -nt -f -d ${paperlessBackupDir}";
        ReadWritePaths = cfg.serviceConfig.ReadWritePaths ++ [paperlessBackupDir];
        Restart = "no";
        Type = "oneshot";
      };
    inherit (cfg) environment;
    requiredBy = ["restic-backups-main.service"];
    before = ["restic-backups-main.service"];
  };

  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [config.services.paperless.port];
  };

  age.secrets.paperless-admin-passwd = {
    generator.script = "alnum";
    mode = "440";
    group = "paperless";
  };
  users.users.paperless.isSystemUser = true;
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 3000;
    passwordFile = config.age.secrets.paperless-admin-passwd.path;
    consumptionDir = "/paperless/consume";
    mediaDir = "/paperless/media";
    settings = {
      PAPERLESS_URL = "https://${paperlessdomain}";
      PAPERLESS_ALLOWED_HOSTS = paperlessdomain;
      PAPERLESS_CORS_ALLOWED_HOSTS = "https://${paperlessdomain}";
      PAPERLESS_TRUSTED_PROXIES = lib.net.cidr.host config.secrets.secrets.global.net.ips.elisabeth config.secrets.secrets.global.net.privateSubnetv4;

      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";

      PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON {
        openid_connect = {
          OAUTH_PKCE_ENABLED = "True";
          APPS = [
            rec {
              provider_id = "kanidm";
              name = "Kanidm";
              client_id = "paperless";
              settings.server_url = "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/${client_id}/.well-known/openid-configuration";
            }
          ];
        };
      };

      # let nginx do all the compression
      PAPERLESS_ENABLE_COMPRESSION = false;
      PAPERLESS_CONSUMER_ENABLE_BARCODES = true;
      PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
      PAPERLESS_CONSUMER_BARCODE_SCANNER = "ZXING";
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_FILENAME_FORMAT = "{owner_username}/{created_year}-{created_month}-{created_day}_{asn}_{title}";
      PAPERLESS_NUMBER_OF_SUGESSTED_DATES = 11;
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TASK_WORKERS = 4;
      PAPERLESS_WEBSERVER_WORKERS = 4;
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/paperless";
      user = "paperless";
      group = "paperless";
      mode = "0750";
    }
  ];
  environment.persistence."/state".directories = [
    {
      directory = paperlessBackupDir;
      user = "paperless";
      group = "paperless";
      mode = "0770";
    }
  ];
  # Mirror the original oauth2 secret
  age.secrets.paperless-oauth2-client-secret = {
    inherit (nodes.elisabeth-kanidm.config.age.secrets.oauth2-paperless) rekeyFile;
    mode = "440";
    group = "paperless";
  };

  systemd.services.paperless-web.script = lib.mkBefore ''
    paperlessClientSecret=$(< ${config.age.secrets.paperless-oauth2-client-secret.path})
    export PAPERLESS_SOCIALACCOUNT_PROVIDERS="$( <<< $PAPERLESS_SOCIALACCOUNT_PROVIDERS ${pkgs.jq}/bin/jq -c --arg paperlessClientSecret "$paperlessClientSecret" '.openid_connect.APPS.[0].secret = $paperlessClientSecret')"
  '';
}
