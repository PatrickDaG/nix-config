{ config, ... }:
{
  globals.services.esphome-nucnix.host = config.node.name;

  environment.persistence."/persist".directories = [
    {
      # The pinned ESPHome module uses a static user, not /var/lib/private/esphome.
      directory = "/var/lib/esphome";
      user = "esphome";
      group = "esphome";
      mode = "0700";
    }
  ];

  services.esphome = {
    enable = true;
    address = "0.0.0.0";
    port = 3001;
  };

  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 3001 ];
  };
  networking.nftables.firewall.rules.mdns = {
    from = [ "untrusted" ];
    to = [ "local" ];
    allowedUDPPorts = [ 5353 ];
  };
}
