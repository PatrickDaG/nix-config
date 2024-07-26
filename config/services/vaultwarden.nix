{
  config,
  lib,
  nodes,
  ...
}:
let
  vaultwardenDomain = "pw.${config.secrets.secrets.global.domains.web}";
in
{
  age.secrets.vaultwarden-env = {
    rekeyFile = config.node.secretsDir + "/vaultwarden-env.age";
    mode = "440";
    group = "vaultwarden";
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/vaultwarden";
      user = "vaultwarden";
      group = "vaultwarden";
      mode = "0700";
    }
  ];

  age.secrets.resticpasswd = {
    generator.script = "alnum";
  };
  age.secrets.vaultwardenHetznerSsh = {
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
        inherit (config.secrets.secrets.global.hetzner.users.vaultwarden) subUid path;
        sshAgeSecret = "vaultwardenHetznerSsh";
      };
      paths = [ config.services.vaultwarden.backupDir ];
      pruneOpts = [
        "--keep-daily 10"
        "--keep-weekly 7"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
    };
  };
  age.secrets.maddyPasswd = {
    generator.script = "alnum";
    group = "vaultwarden";
  };

  nodes.maddy = {
    age.secrets.vaultwardenPasswd = {
      inherit (config.age.secrets.maddyPasswd) rekeyFile;
      inherit (nodes.maddy.config.services.maddy) group;
      mode = "640";
    };
    services.maddy.ensureCredentials = {
      "vaultwarden@${config.secrets.secrets.global.domains.mail_public}".passwordFile =
        nodes.maddy.config.age.secrets.vaultwardenPasswd.path;
    };
  };
  system.activationScripts.systemd_env_smtp_passwd = {
    text = ''
      echo "SMTP_PASSWORD=$(< ${lib.escapeShellArg config.age.secrets.maddyPasswd.path})" > /run/vaultwarden_smtp_passwd
    '';
    deps = [ "agenix" ];
  };

  systemd.services.vaultwarden.serviceConfig.EnvironmentFile = [ "/run/vaultwarden_smtp_passwd" ];

  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    backupDir = "/var/cache/backups/vaultwarden";
    config = {
      dataFolder = lib.mkForce "/var/lib/vaultwarden";
      extendedLogging = true;
      useSyslog = true;
      webVaultEnabled = true;

      rocketAddress = "0.0.0.0";
      rocketPort = 3000;

      signupsAllowed = false;
      passwordIterations = 1000000;
      invitationsAllowed = true;
      invitationOrgName = "Vaultwarden";
      domain = "https://${vaultwardenDomain}";

      smtpHost = "smtp.${config.secrets.secrets.global.domains.mail_public}";
      smtpFrom = "vaultwarden@${config.secrets.secrets.global.domains.mail_public}";
      smtpPort = 465;
      smtpSecurity = "force_tls";
      smtpUsername = "vaultwarden@${config.secrets.secrets.global.domains.mail_public}";
      smtpEmbedImages = true;
    };
    environmentFile = config.age.secrets.vaultwarden-env.path;
  };

  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [ config.services.vaultwarden.config.rocketPort ];
  };

  # Replace uses of old name
  systemd.services.backup-vaultwarden.environment.DATA_FOLDER = lib.mkForce "/var/lib/vaultwarden";
  systemd.services.vaultwarden.serviceConfig = {
    StateDirectory = lib.mkForce "vaultwarden";
    RestartSec = "600"; # Retry every 10 minutes
  };
  environment.persistence."/state".directories = [
    {
      directory = config.services.vaultwarden.backupDir;
      user = "vaultwarden";
      group = "vaultwarden";
      mode = "0770";
    }
  ];
}
