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
      # Modbus Varta element backup
      modbus = {

        name = "mb_varta";
        type = "tcp";
        host = "10.99.30.20"; # replace with your ip of the your varta;
        port = 502;
        delay = 1;
        timeout = 3;
        message_wait_milliseconds = 250;
        sensors =
          ### EMS Software Version { not for Varta link;
          [
            {
              name = "mb_varta_EMS";
              slave = 1;
              address = 1000;
              count = 17;
              data_type = "string";
              precision = 0;
              scale = 1;
            }
            ### ENS Software Version { not for Varta link;
            {
              name = "mb_varta_ENS";
              slave = 1;
              address = 1017;
              count = 17;
              data_type = "string";
              precision = 0;
              scale = 1;
            }
            ### Software Version { not for Varta link;
            {
              name = "mb_varta_software";
              slave = 1;
              address = 1034;
              count = 17;
              data_type = "string";
              precision = 0;
              scale = 1;
            }
            ### Table version;
            {
              name = "mb_varta_table_version";
              slave = 1;
              address = 1051;
              data_type = "uint16";
              precision = "0";
              scale = 1;
              ### timestamp {- not working;
            }
            {
              name = "mb_varta_timestamp";
              slave = 1;
              address = 1052;
              data_type = "uint32";
              swap = "word";
              precision = 0;
              scale = 1;
            }
            ### Serial Number;
            {
              name = "mb_varta_serial";
              slave = 1;
              address = 1054;
              count = 10;
              data_type = "string";
              precision = 0;
              scale = 1;
            }
            ### Number of Battery Modules installed;
            {
              name = "mb_varta_installed_batteries";
              slave = 1;
              address = 1064;
              data_type = "uint16";
              precision = 0;
              scale = 1;
            }
            ### State;
            {
              name = "mb_varta_state";
              slave = 1;
              address = 1065;
              data_type = "uint16";
              precision = 0;
              scale = 1;
              unit_of_measurement = "State";
            }
            ### Active Power { positive=charge / negative: discharge;
            {
              name = "mb_varta_active_power";
              slave = 1;
              address = 1066;
              data_type = "int16";
              precision = 0;
              scale = 1;
              device_class = "power";
              unit_of_measurement = "W";
            }
            ### Apparent Power { positive=charge / negative: discharge;
            {
              name = "mb_varta_apparent_power";
              slave = 1;
              address = 1067;
              data_type = "int16";
              precision = 0;
              scale = 1;
              device_class = "apparent_power";
              unit_of_measurement = "VA";
            }
            ### State of Charge;
            {
              name = "mb_varta_SOC";
              slave = 1;
              address = 1068;
              data_type = "uint16";
              precision = 0;
              scale = 1;
              device_class = "battery";
              unit_of_measurement = "%";
            }
            ### energy counter AC{>DC - not sure if correct;
            {
              name = "mb_varta_ACDC";
              slave = 1;
              address = 1069;
              data_type = "uint32";
              swap = "word";
              precision = 0;
              scale = 1;
              device_class = "energy";
              unit_of_measurement = "Wh";
              state_class = "total_increasing";
            }
            ### Installed capacity;
            {
              name = "mb_varta_capacity";
              slave = 1;
              address = 1071;
              data_type = "uint16";
              precision = 0;
              scale = 10;
              device_class = "energy";
              unit_of_measurement = "Wh";
            }
            ### Grid Power;
            {
              name = "mb_varta_grid_power";
              slave = 1;
              address = 1078;
              data_type = "int16";
              precision = 0;
              scale = 1;
              device_class = "power";
              unit_of_measurement = "W";
            }
          ];
      };

      # Varta input/output
      template.sensor = [
        {
          name = "Varta Input Power";
          unit_of_measurement = "W";
          state_class = "measurement";
          device_class = "power";
          state = ''
            {% if states('sensor.mb_varta_active_power') | float(0) >= 0 %}
            {% set varta_in = states('sensor.mb_varta_active_power') | float(0) %}
            {% else %}
            {% set varta_in = 0 %}
            {% endif %}
            {{ varta_in }}
          '';

        }
        {
          name = "Varta Output Power";
          unit_of_measurement = "W";
          state_class = "measurement";
          device_class = "power";
          state = ''
            {% if states('sensor.mb_varta_active_power') | float(0) <= 0 %}
            {% set varta_out = states('sensor.mb_varta_active_power') | float(0) *-1 %}
            {% else %}
            {% set varta_out = 0 %}
            {% endif %}
            {{ varta_out }}
          '';
        }
      ];

      ##Grid
      sensor = {

        platform = "template";
        sensors = {
          mb_varta_status = {
            friendly_name = "Varta Status";
            value_template = ''
              {% set mapper =  {
                  '0' : 'Busy',
                  '1' : 'Run',
                  '2' : 'Charge',
                  '3' : 'Discharge',
                  '4' : 'Standby',
                  '5' : 'Error',
                  '6' : 'Service',
                  '7' : 'Islanding' } %}
              {% set state =  states.sensor.mb_varta_state.state %}
              {{ mapper[state] if state in mapper else 'Unknown' }}
            '';
          };
        };
      };
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
