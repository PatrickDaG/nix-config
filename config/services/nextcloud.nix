{
  lib,
  pkgs,
  config,
  nodes,
  globals,
  ...
}:
{

  age.secrets.mailnix-passwd = {
    generator.script = "alnum";
    group = "nextcloud";
    mode = "440";
  };

  age.secrets.mailnix-passwd-hash = {
    generator.dependencies = [ config.age.secrets.mailnix-passwd ];
    generator.script = "argon2id";
    mode = "440";
    intermediary = true;
  };
  nodes.mailnix = {
    age.secrets.idmail-nextcloud-passwd-hash = {
      inherit (config.age.secrets.mailnix-passwd-hash) rekeyFile;
      group = "stalwart-mail";
      mode = "440";
    };
    services.idmail.provision.mailboxes."nextcloud@${globals.domains.mail_public}" = {
      password_hash = "%{file:${nodes.mailnix.config.age.secrets.idmail-nextcloud-passwd-hash.path}}%";
      owner = "admin";
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
    hostName = globals.services.nextcloud.domain;
    enable = true;
    package = pkgs.nextcloud31;
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
      trusted_proxies = [ globals.wireguard.services.hosts.nucnix-nginx.ipv4 ];
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
      mail_smtphost = "smtp.${globals.domains.mail_public}";
      mail_smtpport = 465;
      mail_from_address = "nextcloud";
      mail_smtpsecure = "ssl";
      mail_domain = globals.domains.mail_public;
      mail_smtpauth = true;
      mail_smtpname = "nextcloud@${globals.domains.mail_public}";
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
          'mail_smtppassword' => trim(file_get_contents('${config.age.secrets.mailnix-passwd.path}')),
          ];
      '';
    in
    [
      "L+ ${config.services.nextcloud.datadir}/config/mailer.config.php - - - - ${mailer-passwd-conf}"
    ];

  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 80 ];
  };
  globals.wireguard.services-extern.hosts.${config.node.name} = {
    firewallRuleForNode.torweg.allowedTCPPorts = [ 80 ];
  };
  networking = {
    # Use systemd-resolved inside the container
    useHostResolvConf = lib.mkForce false;
  };

  services.resolved.enable = true;
}
