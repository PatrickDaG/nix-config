{ config, ... }:
{
  age.secrets.mosquitto-pw-home_assistant = {
    mode = "440";
    owner = "mosquitto";
    group = "mosquitto";
    generator.script = "alnum";
  };

  services.mosquitto = {
    enable = true;
    persistence = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        users.home_assistant = {
          passwordFile = config.age.secrets.mosquitto-pw-home_assistant.path;
          acl = [ "readwrite #" ];
        };
        settings.allow_anonymous = false;
      }
    ];
  };

  networking.nftables.firewall.rules.mqtt = {
    from = [ "untrusted" ];
    to = [ "local" ];
    allowedTCPPorts = [ 1883 ];
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/mosquitto";
      user = "mosquitto";
      group = "mosquitto";
      mode = "0700";
    }
  ];
}
