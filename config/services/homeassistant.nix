{
  config,
  globals,
  nodes,
  lib,
  pkgs,
  ...
}:
{
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/esphome";
      mode = "0700";
    }
    {
      directory = config.services.home-assistant.configDir;
      user = "hass";
      group = "hass";
      mode = "0700";
    }
  ];

  services.esphome = {
    enable = true;
    address = "0.0.0.0";
    port = 3001;
    #allowedDevices = lib.mkForce ["/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0"];
    # TODO instead deny the zigbee device
  };

  wireguard.services = {
    client.via = "nucnix";
    firewallRuleForNode.${globals.services.nginx.host}.allowedTCPPorts = [
      3000
      3001
    ];
  };
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "radio_browser"
      "met"
      "esphome"
      "fritzbox"
      "homematic"
      "soundtouch"
      "spotify"
      "matter"
      "esphome"
      #"zha"
      "mqtt"
      "ollama"
      "solaredge"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      homematicip_local
      pkgs.havartastorage
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

      # influxdb = {
      #   api_version = 2;
      #   host = globals.services.influxdb.domain;
      #   port = "443";
      #   max_retries = 10;
      #   ssl = true;
      #   verify_ssl = true;
      #   token = "!secret influxdb_token";
      #   organization = "home";
      #   bucket = "home_assistant";
      # };
    };
    extraPackages =
      python3Packages: with python3Packages; [
        psycopg2
        gtts
        fritzconnection
        adguardhome
        aiosolaredge
        zlib-ng
        stringcase
        hahomematic
        pymodbus
      ];
  };
  networking.hosts = {
    "${nodes.${globals.services.adguardhome.host}.config.wireguard.services.ipv4}" = [
      "adguardhome.internal"
    ];
    "${nodes.${globals.services.ollama.host}.config.wireguard.services.ipv4}" = [
      "ollama.internal"
    ];
  };
  age.secrets."home-assistant-secrets.yaml" = {
    rekeyFile = config.node.secretsDir + "/secrets.yaml.age";
    owner = "hass";
  };
  systemd.services.home-assistant = {
    # Update influxdb token
    # We don't use -i because it would require chown with is a @privileged syscall
    # INFLUXDB_TOKEN="$(cat ${config.age.secrets.hass-influxdb-token.path})" \
    #   ${lib.getExe pkgs.yq-go} '.influxdb_token = strenv(INFLUXDB_TOKEN)'
    preStart = lib.mkBefore ''
      if [[ -e ${config.services.home-assistant.configDir}/secrets.yaml ]]; then
        rm ${config.services.home-assistant.configDir}/secrets.yaml
      fi

        cat ${
          config.age.secrets."home-assistant-secrets.yaml".path
        } > ${config.services.home-assistant.configDir}/secrets.yaml

      touch -a ${config.services.home-assistant.configDir}/{automations,scenes,scripts,manual}.yaml
    '';
  };
}
