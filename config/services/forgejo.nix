{
  config,
  globals,
  nodes,
  pkgs,
  lib,
  ...
}:
let
  robots = pkgs.fetchFromGitHub {
    owner = "ai-robots-txt";
    repo = "ai.robots.txt";
    rev = "main";
    hash = "sha256-O/W/gX7EazxzR+ghdxg4i6S0SHEUZoX1afB//HKUNgY=";
  };
in
{
  backups.storageBoxes.main = {
    paths = [ config.services.forgejo.stateDir ];
    subuser = "paperless";
  };

  # Recommended by forgejo: https://forgejo.org/docs/latest/admin/recommendations/#git-over-ssh
  services.openssh.settings.AcceptEnv = [ "GIT_PROTOCOL" ];

  users.groups.git = { };
  users.users.git = {
    isSystemUser = true;
    useDefaultShell = true;
    group = "git";
    home = config.services.forgejo.stateDir;
  };

  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.elisabeth-nginx.allowedTCPPorts = [
      config.services.forgejo.settings.server.HTTP_PORT
    ];
  };
  globals.wireguard.services-extern.hosts.${config.node.name} = {
    firewallRuleForNode.torweg.allowedTCPPorts = [
      config.services.forgejo.settings.server.HTTP_PORT
    ];
  };
  networking.firewall.allowedTCPPorts = [ config.services.forgejo.settings.server.SSH_PORT ];

  environment.persistence."/panzer".directories = [
    {
      directory = config.services.forgejo.stateDir;
      user = "git";
      group = "git";
      mode = "0700";
    }
  ];

  age.secrets.mailnix-passwd = {
    generator.script = "alnum";
    group = "git";
  };

  age.secrets.mailnix-passwd-hash = {
    generator.dependencies = [ config.age.secrets.mailnix-passwd ];
    generator.script = "argon2id";
    mode = "440";
    intermediary = true;
  };
  nodes.mailnix = {
    age.secrets.idmail-forgejo-passwd-hash = {
      inherit (config.age.secrets.mailnix-passwd-hash) rekeyFile;
      group = "stalwart-mail";
      mode = "440";
    };
    services.idmail.provision.mailboxes."forge@${globals.domains.mail_public}" = {
      password_hash = "%{file:${nodes.mailnix.config.age.secrets.idmail-forgejo-passwd-hash.path}}%";
      owner = "admin";
    };
  };

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    # TODO db backups
    # dump.enable = true;
    user = "git";
    group = "git";
    lfs.enable = true;
    secrets.mailer.PASSWD = config.age.secrets.mailnix-passwd.path;
    settings = {
      DEFAULT.APP_NAME = "Patricks tolles git";
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
      database = {
        SQLITE_JOURNAL_MODE = "WAL";
        LOG_SQL = false; # Leaks secrets
      };
      indexer = {
        REPO_INDEXER_ENABLED = true;
      };
      # federation.ENABLED = true;
      mailer = {
        ENABLED = true;
        SMTP_ADDR = "smtp.${globals.domains.mail_public}";
        FROM = "forge@${globals.domains.mail_public}";
        USER = "forge@${globals.domains.mail_public}";
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
        DOMAIN = globals.services.forgejo.domain;
        ROOT_URL = "https://${globals.services.forgejo.domain}/";
        LANDING_PAGE = "login";
        SSH_PORT = 9922;
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
    serviceConfig.RestartSec = "60"; # Retry every minute
    preStart =
      let
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
          "https://auth.${globals.domains.web}/oauth2/openid/${clientId}/.well-known/openid-configuration"
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
        ln --symbolic --force "${robots}/robots.txt" "${config.services.forgejo.customDir}/robots.txt"
      '';
  };

  age.secrets.openid-secret = {
    inherit (nodes.${globals.services.kanidm.host}.config.age.secrets.oauth2-forgejo) rekeyFile;
    mode = "440";
    inherit (config.services.forgejo) group;
  };
}
