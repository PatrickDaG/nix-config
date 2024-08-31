{ config, ... }:
{
  services.invidious = {
    enable = true;
    domain = "yt.${config.secrets.secrets.global.domains.web}";
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

  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [ 3000 ];
  };
}
