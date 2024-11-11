{
  lib,
  pkgs,
  config,
  nodes,
  ...
}:
let
  hostName = "nc.${config.secrets.secrets.global.domains.web}";
in
{
  age.secrets.maddyPasswd = {
    generator.script = "alnum";
    mode = "440";
    owner = "nextcloud";
  };

  nodes.maddy = {
    age.secrets.nextcloudPasswd = {
      inherit (config.age.secrets.maddyPasswd) rekeyFile;
      inherit (nodes.maddy.config.services.maddy) group;
      mode = "640";
    };
    services.maddy.ensureCredentials = {
      "nextcloud@${config.secrets.secrets.global.domains.mail_public}".passwordFile =
        nodes.maddy.config.age.secrets.nextcloudPasswd.path;
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/postgresql/";
      user = "postgres";
      group = "postgres";
      mode = "750";
    }
  ];
  environment.persistence."/panzer".directories = [
    {
      directory = config.services.nextcloud.home;
      user = "nextcloud";
      group = "nextcloud";
      mode = "750";
    }
  ];
  age.secrets.ncpasswd = {
    generator.script = "alnum";
    mode = "440";
    owner = "nextcloud";
  };
  services.postgresql.package = pkgs.postgresql_16;

  services.nextcloud = {
    inherit hostName;
    enable = true;
    package = pkgs.nextcloud30;
    configureRedis = true;
    config.adminpassFile = config.age.secrets.ncpasswd.path; # Kinda ok just remember to instanly change after first setup
    config.adminuser = "admin";
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit
        contacts
        calendar
        tasks
        notes
        phonetrack
        user_oidc
        ;
    };
    maxUploadSize = "4G";
    extraAppsEnable = true;
    database.createLocally = true;
    phpOptions."opcache.interned_strings_buffer" = "32";
    settings = {
      default_phone_region = "DE";
      trusted_proxies = [ nodes.elisabeth.config.wireguard.elisabeth.ipv4 ];
      overwriteprotocol = "https";
      maintenance_window_start = 2;
      enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
      ];

      mail_smtpmode = "smtp";
      mail_smtphost = "smtp.${config.secrets.secrets.global.domains.mail_public}";
      mail_smtpport = 465;
      mail_from_address = "nextcloud";
      mail_smtpsecure = "ssl";
      mail_domain = config.secrets.secrets.global.domains.mail_public;
      mail_smtpauth = true;
      mail_smtpname = "nextcloud@${config.secrets.secrets.global.domains.mail_public}";
      loglevel = 2;
    };
    config = {
      dbtype = "pgsql";
    };
  };
  systemd.tmpfiles.rules =
    let
      mailer-passwd-conf = pkgs.writeText "nextcloud-config.php" ''
        <?php
          $CONFIG = [
          'mail_smtppassword' => trim(file_get_contents('${config.age.secrets.maddyPasswd.path}')),
          ];
      '';
    in
    [
      "L+ ${config.services.nextcloud.datadir}/config/mailer.config.php - - - - ${mailer-passwd-conf}"
    ];

  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [ 80 ];
  };
  networking = {
    # Use systemd-resolved inside the container
    useHostResolvConf = lib.mkForce false;
  };

  services.resolved.enable = true;
}
