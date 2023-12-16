{
  config,
  lib,
  ...
}: {
  age.secrets.cloudflare_token_acme = {
    rekeyFile = ../../secrets/cloudflare/api_token.age;
    mode = "440";
    group = "acme";
  };
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.secrets.secrets.global.devEmail;
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      reloadServices = ["nginx"];
      credentialFiles = {
        "CF_DNS_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
        "CF_ZONE_API_TOKEN_FILE" = config.age.secrets.cloudflare_token_acme.path;
      };
    };
  };
  security.acme.certs = lib.flip lib.mapAttrs config.secrets.secrets.global.domains (_: value: {
    domain = value;
    extraDomainNames = ["*.${value}"];
  });
  users.groups.acme.members = ["nginx"];
}
