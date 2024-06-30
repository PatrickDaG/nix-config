{config, ...}: {
  age.secrets.cloudflare_token_dns = {
    rekeyFile = config.node.secretsDir + "/cloudflare_api_token.age";
    mode = "440";
  };
  # So we only update the A record
  networking.enableIPv6 = false;
  services.ddclient = {
    enable = true;
    zone = config.secrets.secrets.global.domains.web;
    protocol = "Cloudflare";
    username = "token";
    usev4 = "webv4, webv4='https://cloudflare.com/cdn-cgi/trace', webv4-skip='ip='";
    usev6 = "";
    passwordFile = config.age.secrets.cloudflare_token_dns.path;
    domains = [config.secrets.secrets.global.domains.web];
  };
}
