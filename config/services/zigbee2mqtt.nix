{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.zigbee2mqtt = {
    enable = true;
    package = pkgs.zigbee2mqtt_2;
    settings = {
      advanced = {
        log_level = "info";
        channel = 25;
      };
      homeassistant = true;
      permit_join = false;
      serial = {
        adapter = "ember";
        # Zigbee Dongle
        # This is a very bad idea.
        # Hopefully no one else adds any usb devices
        port = "/dev/ttyUSB0";
      };
      mqtt = {
        server = "mqtt://localhost:1883";
        user = "zigbee2mqtt";
        password = "!/run/zigbee2mqtt/secrets.yaml mosquitto-password";
      };
      frontend.port = 3003;
    };
  };
  systemd.services.zigbee2mqtt = {
    serviceConfig = {
      RuntimeDirectory = "zigbee2mqtt";
      LoadCredential = [
        "mosquitto-pw-zigbee2mqtt:${config.age.secrets.mosquitto-pw-zigbee2mqtt.path}"
      ];
    };
    preStart = lib.mkBefore ''
      # Update mosquitto password
      # We don't use -i because it would require chown with is a @privileged syscall
      MOSQUITTO_PW="$(cat "$CREDENTIALS_DIRECTORY/mosquitto-pw-zigbee2mqtt")" \
        ${lib.getExe pkgs.yq-go} '.mosquitto-password = strenv(MOSQUITTO_PW)' \
        /dev/null > /run/zigbee2mqtt/secrets.yaml
    '';
  };
}
