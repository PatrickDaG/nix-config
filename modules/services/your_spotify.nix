{config, ...}: {
  imports = [./your_spotify_m.nix];
  age.secrets.spotify = {
    owner = config.services.your_spotify.user;
    group = config.services.your_spotify.group;
    rekeyFile = ../../secrets/your_spotify.age;
  };
  services.your_spotify = {
    enable = true;
    config = {
      clientEndpoint = "https://spotify.${config.secrets.secrets.global.domains.web}";
    };
    environmentFile = config.age.secrets.spotify.path;
  };
  environment.persistence."/persist".directories = [
    {
      directory = config.services.mongodb.dbpath;
      user = config.services.mongodb.user;
    }
  ];
}
