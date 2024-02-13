{config, ...}: {
  age.secrets.freshrsspasswd = {
    generator.script = "alnum";
    owner = config.services.freshrss.user;
  };
  networking.firewall.allowedTCPPorts = [80];
  services.freshrss = {
    enable = true;
    passwordFile = config.age.secrets.freshrsspasswd.path;
    defaultUser = "patrick";
    baseUrl = "https://rss.lel.lol";
    virtualHost = "rss.lel.lol";
  };
  environment.persistence."/persist".directories = [
    {
      inherit (config.services.freshrss) user;
      directory = config.services.freshrss.dataDir;
      group = config.services.freshrss.user;
      mode = "0750";
    }
  ];
}
