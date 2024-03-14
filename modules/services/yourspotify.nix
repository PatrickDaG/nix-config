{
  config,
  pkgs,
  ...
}: {
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [3000 80];
  };
  imports = [./your_spotify_m.nix];
  age.secrets.spotifySecret = {
    owner = "root";
    mode = "440";
    rekeyFile = config.node.secretsDir + "/spotifySecret.age";
  };
  age.secrets.spotifyPublic = {
    owner = "root";
    mode = "440";
    rekeyFile = config.node.secretsDir + "/spotifyPublic.age";
  };
  services.your_spotify = {
    enable = true;
    spotifySecretFile = config.age.secrets.spotifySecret.path;
    spotifyPublicFile = config.age.secrets.spotifyPublic.path;
    settings = {
      CLIENT_ENDPOINT = "https://sptfy.${config.secrets.secrets.global.domains.web}";
      API_ENDPOINT = "https://apisptfy.${config.secrets.secrets.global.domains.web}";
      MONGO_NO_ADMIN_RIGHTS = false;
    };
    enableLocalDB = true;
    nginxVirtualHost = "sptfy.${config.secrets.secrets.global.domains.web}";
  };
  environment.persistence."/persist".directories = [
    {
      inherit (config.services.mongodb) user;
      directory = config.services.mongodb.dbpath;
    }
  ];
  services.mongodb.package = pkgs.mongodb-bin;
}
