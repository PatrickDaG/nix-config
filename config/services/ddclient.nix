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
    #apparently this module has a default config for both v4 and v6 now
    passwordFile = config.age.secrets.cloudflare_token_dns.path;
    domains = [config.secrets.secrets.global.domains.web];
  };
}
