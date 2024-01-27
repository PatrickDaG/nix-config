{config, ...}: {
  services.maddy = {
    enable = true;
    hostname = "mx1" + config.secrets.secrets.global.domains.mail;
    primaryDomain = config.secrets.secrets.global.domains.mail;
  };
}
