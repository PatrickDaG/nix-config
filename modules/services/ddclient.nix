{config, ...}: {
  age.secrets.cloudflare_token_dns = {
    rekeyFile = ../../secrets/cloudflare/api_token.age;
    mode = "440";
  };
  services.ddclient = {
    enable = true;
    zone = config.secrets.secrets.global.domains.mail;
    protocol = "Cloudflare";
    username = "token";
    passwordFile = config.age.secrets.cloudflare_token_dns.path;
    domains = [config.secrets.secrets.global.domains.mail];
  };
}
