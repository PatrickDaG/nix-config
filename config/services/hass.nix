{
  config,
  globals,
  nodes,
  ...
}:
{
  environment.persistence."/persist".directories = [
    {
      directory = config.services.home-assistant.configDir;
      user = "hass";
      group = "hass";
      mode = "0700";
    }
  ];
  wireguard.services = {
    client.via = "nucnix";
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 3000 ];
  };
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "radio_browser"
      "met"
      "esphome"
      "fritzbox"
      "soundtouch"
      "spotify"
      "matter"
      #"zha"
      "mqtt"
    ];
    config = {
      http = {
        server_host = [ "0.0.0.0" ];
        server_port = 3000;
        use_x_forwarded_for = true;
        trusted_proxies = [ nodes.nucnix-nginx.config.wireguard.services.ipv4 ];
      };

      homeassistant = {
        name = "!secret ha_name";
        latitude = "!secret ha_latitude";
        longitude = "!secret ha_longitude";
        elevation = "!secret ha_elevation";
        currency = "EUR";
        time_zone = "Europe/Berlin";
        unit_system = "metric";
        #external_url = "https://";
        packages = {
          manual = "!include manual.yaml";
        };
      };

      default_config = { };
      ### Components not from default_config

      frontend = {
        #themes = "!include_dir_merge_named themes";
      };

      influxdb = {
        api_version = 2;
        host = globals.services.influxdb.domain;
        port = "443";
        max_retries = 10;
        ssl = true;
        verify_ssl = true;
        token = "!secret influxdb_token";
        organization = "home";
        bucket = "home_assistant";
      };
    };
    extraPackages =
      python3Packages: with python3Packages; [
        psycopg2
        gtts
      ];
  };
}
