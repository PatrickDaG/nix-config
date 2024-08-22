{ config, ... }:
{
  services.invidious = {
    enable = true;
    domain = "yt.${config.secrets.secrets.global.domains.web}";
    settings = {
      external_port = 443;
      https_only = true;
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
