{config, ...}: {
  imports = [./your_spotify_m.nix];
  age.secrets.spotify = {
    inherit (config.services.your_spotify) user group;
    rekeyFile = ../../secrets/your_spotify.age;
  };
  services.your_spotify = {
    enable = true;
    config = {
      clientEndpoint = "https://spotify.${config.secrets.secrets.global.domains.web}";
      apiEndpoint = "https://api.spotify.${config.secrets.secrets.global.domains.web}";
    };
    environmentFile = config.age.secrets.spotify.path;
  };
  environment.persistence."/persist".directories = [
    {
      inherit (config.services.mongodb) user;
      directory = config.services.mongodb.dbpath;
    }
  ];
}
