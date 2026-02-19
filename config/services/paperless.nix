{
  pkgs,
  nodes,
  globals,
  config,
  lib,
  ...
}:
let
  paperlessBackupDir = "/var/cache/backups/paperless";
in
{
  systemd.tmpfiles.settings = {
    "10-paperless".${paperlessBackupDir}.d = {
      inherit (config.services.paperless) user;
      mode = "0770";
    };
  };
  backups.storageBoxes.main = {
    paths = [ paperlessBackupDir ];
    subuser = "paperless";
  };
  systemd.services.paperless-backup =
    let
      cfg = config.systemd.services.paperless-consumer;
    in
    {
      description = "Paperless document backup";
      serviceConfig = lib.recursiveUpdate cfg.serviceConfig {
        ExecStart = "${config.services.paperless.package}/bin/paperless-ngx document_exporter -na -nt -f -d ${paperlessBackupDir}";
        ReadWritePaths = cfg.serviceConfig.ReadWritePaths ++ [ paperlessBackupDir ];
        Restart = "no";
        Type = "oneshot";
      };
      inherit (cfg) environment;
      requiredBy = [ "restic-backups-main.service" ];
      before = [ "restic-backups-main.service" ];
    };

  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.elisabeth-nginx.allowedTCPPorts = [ config.services.paperless.port ];
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
      PAPERLESS_URL = "https://${globals.services.paperless.domain}";
      PAPERLESS_ALLOWED_HOSTS = [
        globals.services.paperless.domain
        globals.wireguard.services.hosts.${config.node.name}.ipv4
      ];
      PAPERLESS_CORS_ALLOWED_HOSTS = "https://${globals.services.paperless.domain}";
      PAPERLESS_TRUSTED_PROXIES = globals.wireguard.services.hosts.elisabeth-nginx.ipv4;

      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";

      PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON {
        openid_connect = {
          OAUTH_PKCE_ENABLED = "True";
          APPS = [
            rec {
              provider_id = "kanidm";
              name = "Kanidm";
              client_id = "paperless";
              settings.server_url = "https://${globals.services.kanidm.domain}/oauth2/openid/${client_id}/.well-known/openid-configuration";
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
    inherit (nodes.${globals.services.kanidm.host}.config.age.secrets.oauth2-paperless) rekeyFile;
    mode = "440";
    group = "paperless";
  };

  systemd.services.paperless-web.script = lib.mkBefore ''
    paperlessClientSecret=$(< ${config.age.secrets.paperless-oauth2-client-secret.path})
    export PAPERLESS_SOCIALACCOUNT_PROVIDERS="$( <<< $PAPERLESS_SOCIALACCOUNT_PROVIDERS ${pkgs.jq}/bin/jq -c --arg paperlessClientSecret "$paperlessClientSecret" '.openid_connect.APPS.[0].secret = $paperlessClientSecret')"
  '';
}
