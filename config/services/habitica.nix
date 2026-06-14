{
  pkgs,
  globals,
  config,
  ...
}:
{
  globals.services.habitica.host = config.node.name;

  services = {
    habitica = {
      enable = true;
      hostName = globals.services.habitica.domain;
    };

    # Set in yyour_spotify
    #mongodb.package = pkgs.mongodb-ce;
  };
}
