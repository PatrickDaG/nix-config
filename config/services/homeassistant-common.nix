{ pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "met"
      "radio_browser"
      "wled"
      "zha"
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
      bar-card
    ];
    extraPackages =
      python3Packages: with python3Packages; [
        psycopg2
        gtts
        fritzconnection
        zlib-ng
        stringcase
        aiohomematic
        hatasmota
        pyipp
        devolo-plc-api
        dwdwfsapi
        wled
        forecast-solar
        aioelectricitymaps
      ];
    config = {
      lovelace.resource_mode = "yaml";
      homeassistant = {
        currency = "EUR";
        time_zone = "Europe/Berlin";
        unit_system = "metric";
      };
      default_config = { };
      "automation ui" = "!include automations.yaml";
    };
  };
}
