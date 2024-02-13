{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [80];
  services.tt-rss = {
    enable = true;
    logDestination = "syslog";
    selfUrlPath = "https://rss.lel.lol";
    virtualHost = "rss.lel.lol";
    themePackages = [
      pkgs.tt-rss-theme-feedly
    ];
    auth = {
      autoLogin = false;
      autoCreate = false;
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/postgresql/";
      user = "postgres";
      group = "postgres";
      mode = "750";
    }
    {
      inherit (config.services.tt-rss) user;
      directory = config.services.tt-rss.root;
      group = config.services.tt-rss.user;
      mode = "0750";
    }
  ];
}
