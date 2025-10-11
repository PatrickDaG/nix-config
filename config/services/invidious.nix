{ config, globals, ... }:
{
  globals.services.invidious.host = config.node.name;
  services.invidious = {
    enable = true;
    port = 3001;
    inherit (globals.services.invidious) domain;
    #sig-helper.enable = true;
    settings = {
      external_port = 443;
      https_only = true;
      popular_enabled = false;
      default_user_preferences = {
        dark_mode = "dark";
        feed_menu = [
          "Subscriptions"
          "Playlists"
          "Trending"
        ];
        default_home = "Subscriptions";
        player_style = "youtube";
        quality = "dash";
        save_player_pos = true;
        local = true;
        extend_desc = true;
      };
    };
  };
  environment.persistence."/persist".directories = [
    { directory = "/var/lib/private/invidious"; }
    {
      directory = "/var/lib/postgresql";
      user = "postgres";
      group = "postgres";
    }
  ];
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ config.services.invidious.port ];
  };
}
