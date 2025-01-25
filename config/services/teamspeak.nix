{ config, ... }:
{
  networking.firewall.allowedUDPPorts = [ config.services.teamspeak3.defaultVoicePort ];
  services.teamspeak3 = {
    enable = true;
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/teamspeak3-server/";
      user = "teamspeak";
      group = "teamspeak";
      mode = "750";
    }
  ];
}
