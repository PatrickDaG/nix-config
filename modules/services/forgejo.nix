{
  config,
  nodes,
  pkgs,
  lib,
  ...
}: let
  forgejoDomain = "git.${config.secrets.secrets.global.domains.web}";
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
      paths = [config.services.forgejo.stateDir];
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

  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [config.services.forgejo.settings.server.HTTP_PORT];
  };
  networking.firewall.allowedTCPPorts = [config.services.forgejo.settings.server.SSH_PORT];

  environment.persistence."/panzer".directories = [
    {
      directory = config.services.forgejo.stateDir;
      user = "forgejo";
      group = "forgejo";
      mode = "0700";
    }
  ];
  age.secrets.forgejo-mailer-passwd = {
    rekeyFile = config.node.secretsDir + "/forgejo-passwd.age";
    owner = "forgejo";
    group = "forgejo";
    mode = "0700";
  };

  services.forgejo = {
    enable = true;
    # TODO db backups
    # dump.enable = true;
    lfs.enable = true;
    mailerPasswordFile = config.age.secrets.forgejo-mailer-passwd.path;
    settings = {
      DEFAULT.APP_NAME = "Patricks tolles git"; # tungsten inert gas?
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
        SMTP_ADDR = config.secrets.secrets.local.forgejo.mail.host;
        FROM = config.secrets.secrets.local.forgejo.mail.from;
        USER = config.secrets.secrets.local.forgejo.mail.user;
        SEND_AS_PLAIN_TEXT = true;
      };
      oauth2_client = {
        ACCOUNT_LINKING = "login";
        ENABLE_AUTO_REGISTRATION = false;
        REGISTER_EMAIL_CONFIRM = false;
        UPDATE_AVATAR = true;
        USERNAME = "nickname";
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
        DOMAIN = forgejoDomain;
        ROOT_URL = "https://${forgejoDomain}/";
        LANDING_PAGE = "login";
        SSH_PORT = 9922;
        # TODO
        # port forwarding in fritz box
        # port forwarding in elisabeth
      };
      service = {
        DISABLE_REGISTRATION = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
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
  systemd.services.forgejo = {
    serviceConfig.RestartSec = "600"; # Retry every 10 minutes
    preStart = let
      exe = lib.getExe config.services.forgejo.package;
      providerName = "kanidm";
      clientId = "forgejo";
      args = lib.escapeShellArgs [
        "--name"
        providerName
        "--provider"
        "openidConnect"
        "--key"
        clientId
        "--auto-discover-url"
        "https://auth.${config.secrets.secrets.global.domains.web}/oauth2/openid/${clientId}/.well-known/openid-configuration"
        "--scopes"
        "email"
        "--scopes"
        "profile"
        "--group-claim-name"
        "groups"
        "--admin-group"
        "admin"
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
    inherit (nodes.elisabeth-kanidm.config.age.secrets.oauth2-forgejo) rekeyFile;
    mode = "440";
    inherit (config.services.forgejo) group;
  };
}
