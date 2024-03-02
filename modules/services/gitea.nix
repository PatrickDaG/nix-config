{
  config,
  pkgs,
  lib,
  ...
}: let
  giteaDomain = "git.${config.secrets.secrets.global.domains.web}";
in {
  age.secrets.resticpasswd = {
    generator.script = "alnum";
  };
  age.secrets.forgejoHetznerSsh = {
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
        inherit (config.secrets.secrets.global.hetzner.users.forgejo) subUid path;
        sshAgeSecret = "forgejoHetznerSsh";
      };
      paths = [config.services.gitea.stateDir];
      pruneOpts = [
        "--keep-daily 10"
        "--keep-weekly 7"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
    };
  };

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
        SMTP_ADDR = config.secrets.secrets.local.gitea.mail.host;
        FROM = config.secrets.secrets.local.gitea.mail.from;
        USER = config.secrets.secrets.local.gitea.mail.user;
        SEND_AS_PLAIN_TEXT = true;
      };
      oauth2_client = {
        ACCOUNT_LINKING = "auto";
        USERNAME = "userid";
        ENABLE_AUTO_REGISTRATION = true;
        OPENID_CONNECT_SCOPES = "email profile";
        REGISTER_EMAIL_CONFIRM = false;
        UPDATE_AVATAR = true;
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
        DISABLE_REGISTRATION = false;
        SHOW_REGISTRATION_BUTTON = false;
        REGISTER_EMAIL_CONFIRM = false;
        ENABLE_NOTIFY_MAIL = true;
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
      };
      session.COOKIE_SECURE = true;
      ui.DEFAULT_THEME = "forgejo-dark";
      "ui.meta" = {
        AUTHOR = "Patrick";
        DESCRIPTION = "Tollstes Forgejo EU-West";
      };
    };
  };

  # XXX: PKCE is currently not supported by gitea/forgejo,
  # see https://github.com/go-gitea/gitea/issues/21376.
  # Disable PKCE manually in kanidm for now.
  # `kanidm system oauth2 warning-insecure-client-disable-pkce forgejo`
  systemd.services.gitea = {
    serviceConfig.RestartSec = "600"; # Retry every 10 minutes
    preStart = let
      exe = lib.getExe config.services.gitea.package;
      providerName = "authelia";
      clientId = "forgejo";
      args = lib.escapeShellArgs [
        "--name"
        providerName
        "--provider"
        "openidConnect"
        "--key"
        clientId
        "--auto-discover-url"
        "https://auth.${config.secrets.secrets.global.domains.web}/.well-known/openid-configuration"
        "--required-claim-name"
        "groups"
        "--group-claim-name"
        "groups"
        "--admin-group"
        "forgejo_admin"
        "--skip-local-2fa"
      ];
    in
      lib.mkAfter ''
        provider_id=$(${exe} admin auth list | ${pkgs.gnugrep}/bin/grep -w '${providerName}' | cut -f1)
          SECRET="$(< ${config.age.secrets.openid-secret.path})"
        if [[ -z "$provider_id" ]]; then
          ${exe} admin auth add-oauth ${args} --secret "$SECRET"
        else
          ${exe} admin auth update-oauth --id "$provider_id" ${args} --secret "$SECRET"
        fi
      '';
  };

  age.secrets.openid-secret = {
    generator.script = "alnum";
    mode = "440";
    inherit (config.services.gitea) group;
  };
}
