{
  config,
  pkgs,
  globals,
  ...
}:
{
  globals.services.yourspotify.host = config.node.name;
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [
      3000
      80
    ];
  };
  age.secrets.spotifySecret = {
    owner = "root";
    mode = "440";
    rekeyFile = config.node.secretsDir + "/spotifySecret.age";
  };
  services.your_spotify = {
    enable = true;
    spotifySecretFile = config.age.secrets.spotifySecret.path;
    settings = {
      SPOTIFY_PUBLIC = "5397a3f2a75949459da343a5e7851bd9";
      CLIENT_ENDPOINT = "https://sptfy.${globals.domains.web}";
      API_ENDPOINT = "https://apisptfy.${globals.domains.web}";
      MONGO_NO_ADMIN_RIGHTS = "false";
    };
    enableLocalDB = true;
    nginxVirtualHost = "sptfy.${globals.domains.web}";
  };
  environment.persistence."/persist".directories = [
    {
      inherit (config.services.mongodb) user;
      directory = config.services.mongodb.dbpath;
    }
  ];
  services.mongodb.package = pkgs.mongodb-bin;
}
