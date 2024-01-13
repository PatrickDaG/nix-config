{
  config,
  pkgs,
  ...
}: let
  giteaDomain = "git.${config.secrets.secrets.global.domains.web}";
in {
  # Recommended by forgejo: https://forgejo.org/docs/latest/admin/recommendations/#git-over-ssh
  services.openssh.settings.AcceptEnv = "GIT_PROTOCOL";
  networking.firewall.allowedTCPPorts = [3000 9922];

  environment.persistence."/panzer".directories = [
    {
      directory = config.services.gitea.stateDir;
      user = "gitea";
      group = "gitea";
      mode = "0700";
    }
  ];
  age.secrets.gitea-mailer-passwd = {
    rekeyFile = config.node.secretsDir + "/gitea-passwd.age";
    owner = "gitea";
    group = "gitea";
    mode = "0700";
  };

  services.gitea = {
    enable = true;
    package = pkgs.forgejo;
    appName = "Patricks tolles git"; # tungsten inert gas?
    stateDir = "/var/lib/forgejo";
    # TODO db backups
    # dump.enable = true;
    lfs.enable = true;
    mailerPasswordFile = config.age.secrets.gitea-mailer-passwd.path;
    settings = {
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
      database = {
        SQLITE_JOURNAL_MODE = "WAL";
        LOG_SQL = false; # Leaks secrets
      };
      # federation.ENABLED = true;
      mailer = {
        ENABLED = true;
        HOST = config.secrets.secrets.local.gitea.mail.host;
        FROM = config.secrets.secrets.local.gitea.mail.from;
        USER = config.secrets.secrets.local.gitea.mail.user;
        SEND_AS_PLAIN_TEXT = true;
      };
      # packages.ENABLED = true;
      repository = {
        DEFAULT_PRIVATE = "private";
        ENABLE_PUSH_CREATE_USER = true;
        ENABLE_PUSH_CREATE_ORG = true;
      };
      server = {
        HTTP_ADDR = "0.0.0.0";
        HTTP_PORT = 3000;
        DOMAIN = giteaDomain;
        ROOT_URL = "https://${giteaDomain}/";
        LANDING_PAGE = "login";
        SSH_PORT = 9922;
        # TODO
        # port forwarding in fritz box
        # port forwarding in elisabeth
      };
      service = {
        DISABLE_REGISTRATION = true;
        ALLOW_ONLY_INTERNAL_REGISTRATION = true;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = false;
        SHOW_REGISTRATION_BUTTON = false;
        REGISTER_EMAIL_CONFIRM = false;
        ENABLE_NOTIFY_MAIL = true;
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
      };
      session.COOKIE_SECURE = true;
      ui.DEFAULT_THEME = "forgejo-auto";
      "ui.meta" = {
        AUTHOR = "Patrick";
        DESCRIPTION = "Tollstes Forgejo EU-West";
      };
    };
  };

  systemd.services.gitea = {
    serviceConfig.RestartSec = "600"; # Retry every 10 minutes
  };
}
