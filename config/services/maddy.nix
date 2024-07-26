# TODO
# autoconfig
{
  config,
  pkgs,
  lib,
  ...
}:
let
  priv_domain = config.secrets.secrets.global.domains.mail_private;
  domain = config.secrets.secrets.global.domains.mail_public;
  mailDomains = [
    priv_domain
    domain
  ];
  maddyBackupDir = "/var/cache/backups/maddy";
in
{
  systemd.tmpfiles.settings = {
    "10-maddy".${maddyBackupDir}.d = {
      inherit (config.services.maddy) user group;
      mode = "0770";
    };
  };

  age.secrets.resticpasswd = {
    generator.script = "alnum";
  };
  age.secrets.maddyHetznerSsh = {
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
        inherit (config.secrets.secrets.global.hetzner.users.maddy) subUid path;
        sshAgeSecret = "maddyHetznerSsh";
      };
      paths = [
        "/var/lib/maddy/messages"
        maddyBackupDir
      ];
      pruneOpts = [
        "--keep-daily 10"
        "--keep-weekly 7"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
    };
  };
  systemd.services.maddy-backup =
    let
      cfg = config.systemd.services.maddy;
    in
    {
      description = "Maddy db backup";
      serviceConfig = lib.recursiveUpdate cfg.serviceConfig {
        ExecStart = "${pkgs.sqlite}/bin/sqlite3 /var/lib/maddy/imapsql.db \".backup '${maddyBackupDir}/imapsql.sqlite3'\"";
        Restart = "no";
        Type = "oneshot";
      };
      inherit (cfg) environment;
      requiredBy = [ "restic-backups-main.service" ];
      before = [ "restic-backups-main.service" ];
    };

  age.secrets.patrickPasswd = {
    generator.script = "alnum";
    owner = "maddy";
    group = "maddy";
  };
  # Opening ports for additional TLS listeners. This is not yet
  # implemented in the module.
  networking.firewall.allowedTCPPorts = [
    993
    465
  ];
  services.maddy = {
    enable = true;
    hostname = "mx1." + domain;
    primaryDomain = domain;
    localDomains = mailDomains;
    tls = {
      certificates = [
        {
          keyPath = "${config.security.acme.certs.mail_public.directory}/key.pem";
          certPath = "${config.security.acme.certs.mail_public.directory}/fullchain.pem";
        }
      ];
      loader = "file";
    };
    ensureCredentials = {
      "patrick@${domain}".passwordFile = config.age.secrets.patrickPasswd.path;
    };
    ensureAccounts = [ "patrick@${domain}" ];
    openFirewall = true;
    config = ''
      ## Maddy Mail Server - default configuration file (2022-06-18)
      # Suitable for small-scale deployments. Uses its own format for local users DB,
      # should be managed via maddy subcommands.
      #
      # See tutorials at https://maddy.email for guidance on typical
      # configuration changes.

      # ----------------------------------------------------------------------------
      # Local storage & authentication

      # pass_table provides local hashed passwords storage for authentication of
      # users. It can be configured to use any "table" module, in default
      # configuration a table in SQLite DB is used.
      # Table can be replaced to use e.g. a file for passwords. Or pass_table module
      # can be replaced altogether to use some external source of credentials (e.g.
      # PAM, /etc/shadow file).
      #
      # If table module supports it (sql_table does) - credentials can be managed
      # using 'maddy creds' command.

      auth.pass_table local_authdb {
          table sql_table {
              driver sqlite3
              dsn credentials.db
              table_name passwords
          }
      }

      # imapsql module stores all indexes and metadata necessary for IMAP using a
      # relational database. It is used by IMAP endpoint for mailbox access and
      # also by SMTP & Submission endpoints for delivery of local messages.
      #
      # IMAP accounts, mailboxes and all message metadata can be inspected using
      # imap-* subcommands of maddy.

      storage.imapsql local_mailboxes {
          driver sqlite3
          dsn imapsql.db
      }

      # ----------------------------------------------------------------------------
      # SMTP endpoints + message routing

      table.chain local_rewrites {
          # Reroute everything to me
          optional_step regexp ".*" "patrick@${domain}"
      }

      msgpipeline local_routing {
          # Insert handling for special-purpose local domains here.
          # e.g.
          # destination lists.example.org {
          #     deliver_to lmtp tcp://127.0.0.1:8024
          # }

          destination $(local_domains) {
              modify {
                  replace_rcpt &local_rewrites
              }

              deliver_to &local_mailboxes
          }

          default_destination {
              reject 550 5.1.1 "User doesn't exist"
          }
      }

      smtp tcp://0.0.0.0:25 {
          limits {
              # Up to 20 msgs/sec across max. 10 SMTP connections.
              all rate 20 1s
              all concurrency 10
          }

          dmarc yes
          max_message_size 256M
          check {
              require_mx_record
              dkim
              spf
          }

          source $(local_domains) {
              reject 501 5.1.8 "Use Submission for outgoing SMTP"
          }
          default_source {
              destination postmaster $(local_domains) {
                  deliver_to &local_routing
              }
              default_destination {
                  reject 550 5.1.1 "User doesn't exist"
              }
          }
      }

      submission tls://0.0.0.0:465 {
          limits {
              # Up to 50 msgs/sec across any amount of SMTP connections.
              all rate 50 1s
          }

          auth &local_authdb

          source $(local_domains) {
              check {
                  authorize_sender {
                      user_to_email table.chain {
                        optional_step static {
                          entry patrick@${domain} "*"
                        }
                        step identity
                      }
                  }
              }

              destination $(local_domains) {
                  deliver_to &local_routing
              }
              default_destination {
                  modify {
                      dkim $(primary_domain) $(local_domains) default
                  }
                  deliver_to &remote_queue
              }
          }
          default_source {
              reject 501 5.1.8 "Non-local sender domain"
          }
      }

      target.remote outbound_delivery {
          limits {
              # Up to 20 msgs/sec across max. 10 SMTP connections
              # for each recipient domain.
              destination rate 20 1s
              destination concurrency 10
          }
          mx_auth {
              dane
              mtasts {
                  cache fs
                  fs_dir mtasts_cache/
              }
              local_policy {
                  min_tls_level encrypted
                  min_mx_level none
              }
          }
      }

      target.queue remote_queue {
          target &outbound_delivery

          autogenerated_msg_domain $(primary_domain)
          bounce {
              destination postmaster $(local_domains) {
                  deliver_to &local_routing
              }
              default_destination {
                  reject 550 5.0.0 "Refusing to send DSNs to non-local addresses"
              }
          }
      }

      # ----------------------------------------------------------------------------
      # IMAP endpoints

      imap tls://0.0.0.0:993 {
          auth &local_authdb
          storage &local_mailboxes
      }
    '';
  };
  services.nginx.virtualHosts = lib.mkMerge [
    # For each mail domain, add MTA STS entry via nginx
    (lib.genAttrs (map (x: "mta-sts.${x}") mailDomains) (domain: {
      forceSSL = true;
      useACMEWildcardHost = true;
      locations."=/.well-known/mta-sts.txt".alias = pkgs.writeText "mta-sts.${domain}.txt" ''
        version: STSv1
        mode: enforce
        mx: mx1.${domain}
        max_age: 86400
      '';
    }))
    # For each mail domain, add an autoconfig xml file for Thunderbird
    (lib.genAttrs (map (x: "autoconfig.${x}") mailDomains) (domain: {
      forceSSL = true;
      useACMEWildcardHost = true;
      locations."=/mail/config-v1.1.xml".alias =
        pkgs.writeText "autoconfig.${domain}.xml"
          # xml
          ''
            <?xml version="1.0" encoding="UTF-8"?>
            <clientConfig version="1.1">
              <emailProvider id="${domain}">
                <domain>${domain}</domain>
                <displayName>%EMAILADDRESS%</displayName>
                <displayShortName>%EMAILLOCALPART%</displayShortName>
                <incomingServer type="imap">
                  <hostname>mail.${domain}</hostname>
                  <port>993</port>
                  <socketType>SSL</socketType>
                  <authentication>password-cleartext</authentication>
                  <username>%EMAILADDRESS%</username>
                </incomingServer>
                <outgoingServer type="smtp">
                  <hostname>mail.${domain}</hostname>
                  <port>465</port>
                  <socketType>SSL</socketType>
                  <authentication>password-cleartext</authentication>
                  <username>%EMAILADDRESS%</username>
                </outgoingServer>
              </emailProvider>
            </clientConfig>
          '';
    }))
  ];
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/maddy";
      user = "maddy";
      group = "maddy";
      mode = "0755";
    }
  ];
}
