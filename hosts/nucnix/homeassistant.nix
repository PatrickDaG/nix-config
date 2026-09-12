{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
{
  globals.services.homeassistant-nucnix.host = config.node.name;

  environment.persistence."/persist".directories = [
    {
      directory = config.services.home-assistant.configDir;
      user = "hass";
      group = "hass";
      mode = "0700";
    }
  ];

  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 3000 ];
  };
  networking.nftables.firewall.rules.mdns = {
    from = [ "untrusted" ];
    to = [ "local" ];
    allowedUDPPorts = [ 5353 ];
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "met"
      "radio_browser"
      "wake_on_lan"
      "wled"
    ];
    customComponents = [ pkgs.home-assistant-custom-components.bambu-lab ];
    config = {
      http = {
        server_host = globals.wireguard.services.hosts.${config.node.name}.ipv4;
        server_port = 3000;
        use_x_forwarded_for = true;
        trusted_proxies = [ globals.wireguard.services.hosts.nucnix-nginx.ipv4 ];
      };
      wake_on_lan = { };
      homeassistant = {
        name = "nucnix";
        external_url = "https://${globals.services.homeassistant-nucnix.domain}";
        # Set the home location during onboarding, independently of the old instance.
        unit_system = "metric";
        currency = "EUR";
        time_zone = "Europe/Berlin";
      };
      default_config = { };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";
    };
  };

  systemd.services.home-assistant.preStart = lib.mkBefore ''
    touch ${config.services.home-assistant.configDir}/{automations,scenes,scripts}.yaml
  '';
}
