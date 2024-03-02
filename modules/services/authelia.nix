{config, ...}: let
  stateDir = "/var/lib/authelia-main";
in {
  age.secrets.jwtSecretFile = {
    generator.script = "alnum";
    mode = "440";
    inherit (config.authelia.instances.main) group;
  };

  age.secrets.sessionSecretFile = {
    generator.script = "alnum";
    mode = "440";
    inherit (config.authelia.instances.main) group;
  };

  age.secrets.storageEncryptionKeyFile = {
    generator.script = "alnum";
    mode = "440";
    inherit (config.authelia.instances.main) group;
  };

  age.secrets.oidcHmacSecretFile = {
    generator.script = "alnum";
    mode = "440";
    inherit (config.authelia.instances.main) group;
  };

  age.secrets.oidcIssuerPrivateKeyFile = {
    generator.script = {pkgs, ...}: ''
      ${pkgs.openssl}/bin/openssl genrsa --outform PEM 4096
    '';
    mode = "440";
    inherit (config.authelia.instances.main) group;
  };

  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = config.age.secrets.jwtSecretsFile.path;
      sessionSecretFile = config.age.secrets.sessionSecretFile.path;
      storageEncryptionKeyFile = config.age.secrets.storageEncryptionKeyFile.path;
      oidcHmacSecretFile = config.age.secrets.oidcHmacSecretFile.path;
      oidcIssuerPrivateKeyFile = config.age.secrets.oidcIssuerPrivateKeyFile.path;
    }; # TODO
    settings = {
      session = {
        domain = config.secrets.secrets.global.domains.web;
      };
      totp.disable = true;
      dua_api.disable = true;
      ntp.disable_startup_check = true;
      theme = "dark";
      default_2fa_method = "webauthn";
      server.host = "0.0.0.0";

      authentication_backend = {
        password_reset.disable = true;
        file = {
          path =
            builtins.toJSON {
            };
        };
      };
      password_policy.standard = {
        enabled = true;
        min_length = 32;
      };
      storage.local.path = "${stateDir}/db.sqlite3";
      identity_providers.oidc.clients = [
        {
          id = "forgejo";
          secret = "";
          redirect_uris = ["git.${config.secrets.secrets.global.domains.web}/user/oauth2/authelia/callback"];
          public = false;
          scopes = ["openid" "email" "profile" "groups"];
        }
      ];
    };
  };
}
