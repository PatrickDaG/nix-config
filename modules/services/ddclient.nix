{config, ...}: {
  age.secrets.cloudflare_token_dns = {
    rekeyFile = ../../secrets/cloudflare/api_token.age;
    mode = "440";
  };
  # So we only update the A record
  networking.enableIPv6 = false;
  services.ddclient = {
    enable = true;
    zone = config.secrets.secrets.global.domains.web;
    protocol = "Cloudflare";
    username = "token";
    use = "web, web='https://cloudflare.com/cdn-cgi/trace', web-skip='ip='";
    passwordFile = config.age.secrets.cloudflare_token_dns.path;
    domains = [config.secrets.secrets.global.domains.web];
  };
}
