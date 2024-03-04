{config, ...}: {
  imports = [./your_spotify_m.nix];
  age.secrets.spotify = {
    owner = "your_spotify";
    mode = "440";
    rekeyFile = config.node.secretsDir + "/yourspotify.age";
  };
  services.your_spotify = {
    #enable = true;
    settings = {
      CLIENT_ENDPOINT = "https://spotify.${config.secrets.secrets.global.domains.web}";
      API_ENDPOINT = "https://api.spotify.${config.secrets.secrets.global.domains.web}";
    };
    enableLocalDB = true;
    enableNginxVirtualHost = true;
    environmentFile = config.age.secrets.spotify.path;
  };
  environment.persistence."/persist".directories = [
    {
      inherit (config.services.mongodb) user;
      directory = config.services.mongodb.dbpath;
    }
  ];
}
