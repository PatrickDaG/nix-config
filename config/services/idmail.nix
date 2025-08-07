{
  config,
  globals,
  pkgs,
  ...
}:
let
  domain = globals.domains.mail_public;
  idmailDomain = globals.services.idmail.domain;
  priv_domain = globals.domains.mail_private;
  priv_domain2 = globals.domains.mail_private2;

  mkRandomSecret = {
    generator.script = "alnum";
    mode = "000";
    intermediary = true;
  };

  mkArgon2id = secret: {
    generator.dependencies = [ config.age.secrets.${secret} ];
    generator.script = "argon2id";
    mode = "440";
    group = "stalwart-mail";
  };
in
{
  environment.persistence."/persist".directories = [
    {
      directory = config.services.idmail.dataDir;
      user = "stalwart-mail";
      group = "stalwart-mail";
      mode = "4770";
    }
  ];

  age.secrets = {
    idmail-user-pw_admin = mkRandomSecret;
    idmail-user-hash_admin = mkArgon2id "idmail-user-pw_admin";
    idmail-user-pw_patrick = mkRandomSecret;
    idmail-user-hash_patrick = mkArgon2id "idmail-user-pw_admin";
    idmail-user-pw_david = mkRandomSecret;
    idmail-user-hash_david = mkArgon2id "idmail-user-pw_admin";
    idmail-mailbox-pw_catch-all = mkRandomSecret;
    idmail-mailbox-hash_catch-all = mkArgon2id "idmail-mailbox-pw_catch-all";
    idmail-mailbox-pw_postmaster = mkRandomSecret;
    idmail-mailbox-hash_postmaster = mkArgon2id "idmail-mailbox-pw_postmaster";
  };

  services.idmail = {
    package = pkgs.idmail;
    enable = true;
    # Stalwart will change permissions due to SQLite implementation.
    # Therefore, run as stalwart-mail since we don't allow reading
    # stalwarts folder anyway (sandboxing is on).
    user = "stalwart-mail";
    provision = {
      enable = true;
      users.admin = {
        admin = true;
        password_hash = "%{file:${config.age.secrets.idmail-user-hash_admin.path}}%";
      };
      users.patrick = {
        admin = true;
        password_hash = "%{file:${config.age.secrets.idmail-user-hash_patrick.path}}%";
      };
      users.david = {
        admin = true;
        password_hash = "%{file:${config.age.secrets.idmail-user-hash_david.path}}%";
      };
      domains = {
        "${domain}" = {
          owner = "admin";
          catch_all = "catch-all@${domain}";
          public = true;
        };
        "${priv_domain}" = {
          owner = "patrick";
          catch_all = "catch-all@${domain}";
          public = false;
        };
        "${priv_domain2}" = {
          owner = "david";
          catch_all = "catch-all@${domain}";
          public = false;
        };
      };
      mailboxes = {
        "catch-all@${domain}" = {
          password_hash = "%{file:${config.age.secrets.idmail-mailbox-hash_catch-all.path}}%";
          owner = "admin";
        };
        "postmaster@${domain}" = {
          password_hash = "%{file:${config.age.secrets.idmail-mailbox-hash_postmaster.path}}%";
          owner = "admin";
        };
      };
    };
  };
  systemd.services.idmail.serviceConfig.RestartSec = "60"; # Retry every minute

  services.nginx = {
    enable = true;
    recommendedSetup = true;
    upstreams.idmail = {
      servers."127.0.0.1:3000" = { };
      extraConfig = ''
        zone idmail 64k;
        keepalive 2;
      '';
    };
    virtualHosts.${idmailDomain} = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://idmail";
        proxyWebsockets = true;
      };
    };
  };
}
