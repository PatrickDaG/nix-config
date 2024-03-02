{
  config,
  pkgs,
  ...
}: let
  stateDir = "/var/lib/authelia-main";
in {
  age.secrets.jwtSecretFile = {
    generator.script = "alnum";
    mode = "440";
    inherit (config.services.authelia.instances.main) group;
  };

  age.secrets.sessionSecretFile = {
    generator.script = "alnum";
    mode = "440";
    inherit (config.services.authelia.instances.main) group;
  };

  age.secrets.storageEncryptionKeyFile = {
    generator.script = "alnum";
    mode = "440";
    inherit (config.services.authelia.instances.main) group;
  };

  age.secrets.oidcHmacSecretFile = {
    generator.script = "alnum";
    mode = "440";
    inherit (config.services.authelia.instances.main) group;
  };

  age.secrets.oidcIssuerPrivateKeyFile = {
    generator.script = {pkgs, ...}: ''
      ${pkgs.openssl}/bin/openssl genrsa 4096
    '';
    mode = "440";
    inherit (config.services.authelia.instances.main) group;
  };
  networking.firewall.allowedTCPPorts = [config.services.authelia.instances.main.settings.server.port];

  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = config.age.secrets.jwtSecretFile.path;
      sessionSecretFile = config.age.secrets.sessionSecretFile.path;
      storageEncryptionKeyFile = config.age.secrets.storageEncryptionKeyFile.path;
      oidcHmacSecretFile = config.age.secrets.oidcHmacSecretFile.path;
      oidcIssuerPrivateKeyFile = config.age.secrets.oidcIssuerPrivateKeyFile.path;
    }; # TODO
    settings = {
      session = {
        domain = config.secrets.secrets.global.domains.web;
      };
      webauthn.disable = true;
      duo_api.disable = true;
      ntp.disable_startup_check = true;
      theme = "dark";
      default_2fa_method = "totp";
      server.host = "0.0.0.0";
      access_control.default_policy = "one_factor";
      webauthn = {
        attestation_conveyance_preference = "none";
        user_verification = "discouraged";
      };

      authentication_backend = {
        password_reset.disable = true;
        file = {
          path = pkgs.writeText "user-db" (builtins.toJSON {
            users.patrick = {
              disabled = false;
              displayname = "Patrick";
              password = "$argon2id$v=19$m=4096,t=3,p=1$Ym5yc3VhZHJub2I$ihbPHC697Nybk1H7WHCMKi+2KkvNhdwvScaorkkj5yM";
              email = "patrick@${config.secrets.secrets.global.domains.mail_public}";
              groups = ["admin" "forgejo_admin"];
            };
          });
        };
      };
      password_policy.standard = {
        enabled = true;
        min_length = 32;
      };
      notifier.filesystem.filename = "${stateDir}/notifications.txt";
      storage.local.path = "${stateDir}/db.sqlite3";
      identity_providers.oidc.clients = [
        {
          id = "forgejo";
          secret = "$argon2id$v=19$m=4096,t=3,p=1$Ym5yc3VhZHJub2I$0gZRilVu8O1rmVxX+ZTMFFHqya6YN8l+8QXFIorhtKM";
          redirect_uris = ["https://git.${config.secrets.secrets.global.domains.web}/user/oauth2/authelia/callback"];
          public = false;
          scopes = ["openid" "email" "profile" "groups"];
        }
      ];
    };
  };
}
