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

  globals.services.esphome.host = config.node.name;
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
  networking.nftables.firewall.zones.devices.interfaces = [ "mv-devices" ];
  networking.nftables.firewall.zones.iot.interfaces = [ "mv-iot" ];
  networking.nftables.firewall = {
    rules = {
      mqtt = {
        from = [
          "devices"
          "iot"
        ];
        to = [ "local" ];
        allowedTCPPorts = [ 1883 ];
      };
      homematic = {
        from = [
          "devices"
        ];
        to = [ "local" ];
        allowedTCPPorts = [ 45053 ];
      };
      mdns = {
        from = [
          "devices"
          "iot"
        ];
        to = [ "local" ];
        allowedUDPPorts = [ 5353 ];
      };
    };
  };
  age.secrets.mosquitto-pw-home_assistant = {
    mode = "440";
    owner = "hass";
    group = "mosquitto";
    generator.script = "alnum";
  };
  services.mosquitto = {
    enable = true;
    persistence = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        users = {
          home_assistant = {
            passwordFile = config.age.secrets.mosquitto-pw-home_assistant.path;
            acl = [ "readwrite #" ];
          };
        };
        settings.allow_anonymous = false;
      }
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

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      bubble-card
      weather-card
      mini-graph-card
      card-mod
      mushroom
      multiple-entity-row
      button-card
      weather-chart-card
      hourly-weather
    ];
    config = {
      http = {
        server_host = [ "0.0.0.0" ];
        server_port = 3000;
        use_x_forwarded_for = true;
        trusted_proxies = [ nodes.nucnix-nginx.config.wireguard.services.ipv4 ];
      };
      lovelace.mode = "yaml";

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
        themes = "!include_dir_merge_named themes";
      };
      "automation ui" = "!include automations.yaml";

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
            ### Active Power Exponent;
            {
              name = "mb_varta_active_power_exponent";
              slave = 1;
              address = 2066;
              data_type = "int16";
              device_class = "power";
            }
            ### Apparent Power Exponent;
            {
              name = "mb_varta_apparent_power_exponent";
              slave = 1;
              address = 2067;
              data_type = "int16";
              device_class = "power";
            }
            ### Enegrey Counter Exponent;
            {
              name = "mb_varta_energy_counter_exponent";
              slave = 1;
              address = 2069;
              data_type = "int16";
              device_class = "power";
            }
            ### Capacity Counter Exponent;
            {
              name = "mb_varta_capacity_exponent";
              slave = 1;
              address = 2071;
              data_type = "int16";
              device_class = "power";
            }
            ### Grid Power Exponent;
            {
              name = "mb_varta_grid_power_exponent";
              slave = 1;
              address = 2078;
              data_type = "int16";
              device_class = "power";
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
        hatasmota
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
  systemd.services.home-assistant.preStart =
    let
      modules = [
        (pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "home-assistant";
          rev = "e877188ca467e7bbe8991440f6b5f6b3d30347fc";
          hash = "sha256-eUqYlaXNLPfaKn3xcRm5AQwTOKf70JF8cepibBb9KXc=";
        })
        (pkgs.fetchFromGitHub {
          owner = "flejz";
          repo = "hass-cyberpunk-2077-theme";
          rev = "78077ad6298a5bbbc8de4c72858b43cedebaae12";
          hash = "sha256-gSlykxPBKji7hAX9E2L7dDtK3zNcRvRjCq2+apgMjFg=";
        })
        (pkgs.fetchFromGitHub {
          owner = "Madelena";
          repo = "Metrology-for-Hass";
          rev = "3e858768d5afba3f83de0d3fe836336cb20f11ea";
          hash = "sha256-IBKIB5KandpjWyVQYXuUvTL3gHHjTLr7saskkqq3A0w=";
        })
        (pkgs.fetchFromGitHub {
          owner = "ricardoquecria";
          repo = "caule-themes-pack-1";
          rev = "0ec8a4b7acf63d8618bcf2fdd968d6256e998acb";
          hash = "sha256-biNz3ZO3nFfEgchoPu9M3lXiTj9BDxkUaZiCNq0Jy8M=";
        })
        (pkgs.fetchFromGitHub {
          owner = "TilmanGriesel";
          repo = "graphite";
          rev = "bce4342b9f2423a14a09af703f6d22f9660d764e";
          hash = "sha256-ZniV5Sw00ml1AaPx7oQZ1oorj01TLamrZV/a2wS8jVg=";
        })
        (pkgs.fetchFromGitHub {
          owner = "am80l";
          repo = "sundown";
          rev = "bdfa827a2d3e524dae9637724053bf19567bbe5b";
          hash = "sha256-PpqufsjWukAM/gQpet/m+n2+nQQWGVeow6F4yXI+oG8=";
        })
        (pkgs.fetchFromGitHub {
          owner = "bbbenji";
          repo = "synthwave-hass";
          rev = "332617a96c3325dd845f90ff79f2a1f995a5006b";
          hash = "sha256-zi6VNhKUlqy4VAMMqGL09V6RdIKxikkkEPp3+GyYhmg=";
        })
      ];
    in
    lib.mkBefore (
      ''
        if [[ -e ${config.services.home-assistant.configDir}/secrets.yaml ]]; then
          rm ${config.services.home-assistant.configDir}/secrets.yaml
        fi

          cat ${
            config.age.secrets."home-assistant-secrets.yaml".path
          } > ${config.services.home-assistant.configDir}/secrets.yaml

        touch -a ${config.services.home-assistant.configDir}/{automations,scenes,scripts,manual}.yaml
        mkdir -p ${config.services.home-assistant.configDir}/themes
      ''
      + lib.concatStringsSep "\n" (
        lib.flip map modules (x: ''
          for i in ${x}/themes/*; do
            ln -fFns "$i" ${config.services.home-assistant.configDir}/themes/"$(basename "$i")"
          done
          for i in ${x}/www/*; do
            ln -fFns "$i" ${config.services.home-assistant.configDir}/www/"$(basename "$i")"
          done
        '')
      )
    );

}
