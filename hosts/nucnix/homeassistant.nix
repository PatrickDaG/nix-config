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

  globals.wireguard.services-flat.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 8123 ];
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
      "zha"
    ];
    customComponents = [ pkgs.home-assistant-custom-components.bambu-lab ];
    config = {
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
