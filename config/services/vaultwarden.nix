{
  config,
  lib,
  nodes,
  globals,
  ...
}:
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
        inherit (globals.hetzner) mainUser;
        inherit (globals.hetzner.users.vaultwarden) subUid path;
        sshAgeSecret = "vaultwardenHetznerSsh";
      };
      paths = [ config.services.vaultwarden.backupDir ];
      #pruneOpts = [
      #  "--keep-daily 10"
      #  "--keep-weekly 7"
      #  "--keep-monthly 12"
      #  "--keep-yearly 75"
      #];
    };
  };
  age.secrets.mailnix-passwd = {
    generator.script = "alnum";
  };

  age.secrets.mailnix-passwd-hash = {
    generator.dependencies = [ config.age.secrets.mailnix-passwd ];
    generator.script = "argon2id";
    mode = "440";
    intermediary = true;
  };
  nodes.mailnix = {
    age.secrets.idmail-vaultwarden-passwd-hash = {
      inherit (config.age.secrets.mailnix-passwd-hash) rekeyFile;
      group = "stalwart-mail";
      mode = "440";
    };
    services.idmail.provision.mailboxes."vaultwarden@${globals.domains.mail_public}" = {
      password_hash = "%{file:${nodes.mailnix.config.age.secrets.idmail-vaultwarden-passwd-hash.path}}%";
      owner = "admin";
    };
  };
  system.activationScripts.systemd_env_smtp_passwd = {
    text = ''
      echo "SMTP_PASSWORD=$(< ${lib.escapeShellArg config.age.secrets.mailnix-passwd.path})" > /run/vaultwarden_smtp_passwd
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

      allowedConnectSrc = "https://${globals.services.idmail.domain}/api/ ";

      signupsAllowed = false;
      passwordIterations = 1000000;
      invitationsAllowed = true;
      invitationOrgName = "Vaultwarden";
      domain = "https://${globals.services.vaultwarden.domain}";

      smtpHost = "smtp.${globals.domains.mail_public}";
      smtpFrom = "vaultwarden@${globals.domains.mail_public}";
      smtpPort = 465;
      smtpSecurity = "force_tls";
      smtpUsername = "vaultwarden@${globals.domains.mail_public}";
      smtpEmbedImages = true;
    };
    environmentFile = config.age.secrets.vaultwarden-env.path;
  };

  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [
      config.services.vaultwarden.config.rocketPort
    ];
  };
  globals.wireguard.services-extern.hosts.${config.node.name} = {
    firewallRuleForNode.torweg.allowedTCPPorts = [
      config.services.vaultwarden.config.rocketPort
    ];
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
  globals.monitoring.http.vaultwarden = {
    url = config.services.vaultwarden.config.domain;
    expectedBodyRegex = "Vaultwarden Web";
    network = "internet";
  };
}
