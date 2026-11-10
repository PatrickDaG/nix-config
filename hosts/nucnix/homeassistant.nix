{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ../../config/services/homeassistant-common.nix ];

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
    extraComponents = [ "wake_on_lan" ];
    customComponents = [ pkgs.home-assistant-custom-components.bambu-lab ];
    config = {
      wake_on_lan = { };
      homeassistant = {
        name = "nucnix";
        external_url = "https://${globals.services.homeassistant-nucnix.domain}";
        # Set the home location during onboarding, independently of the old instance.
      };
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";
    };
  };

  systemd.services.home-assistant.preStart = lib.mkBefore ''
    touch ${config.services.home-assistant.configDir}/{automations,scenes,scripts}.yaml
  '';
}
