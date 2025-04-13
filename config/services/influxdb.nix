{
  config,
  pkgs,
  ...
}:
let
  influxdbPort = 8086;
in
{
  networking.nftables.firewall.rules.ingress = {
    from = [
      "wg-monitoring"
    ];
    to = [ "local" ];
    allowedTCPPorts = [ influxdbPort ];

  };
  globals.services.influxdb.host = config.node.name;

  age.secrets.influxdb-admin-password = {
    generator.script = "alnum";
    mode = "440";
    group = "influxdb2";
  };

  age.secrets.influxdb-admin-token = {
    generator.script = "alnum";
    mode = "440";
    group = "influxdb2";
  };

  environment.persistence."/panzer".directories = [
    {
      directory = "/var/lib/influxdb2";
      user = "influxdb2";
      group = "influxdb2";
      mode = "0700";
    }
  ];

  services.influxdb2 = {
    enable = true;
    settings = {
      reporting-disabled = true;
      http-bind-address = "0.0.0.0:${toString influxdbPort}";
    };
    provision = {
      enable = true;
      initialSetup = {
        organization = "default";
        bucket = "default";
        passwordFile = config.age.secrets.influxdb-admin-password.path;
        tokenFile = config.age.secrets.influxdb-admin-token.path;
      };
      organizations.machines.buckets.telegraf = { };
      organizations.home.buckets.home_assistant = { };
    };
  };

  environment.systemPackages = [ pkgs.influxdb2-cli ];

  systemd.services.grafana.serviceConfig.RestartSec = "60"; # Retry every minute

  age.secrets."grafana-influxdb-token-machines-${config.node.name}" = {
    inherit (config.age.secrets.grafana-influxdb-token-machines) rekeyFile;
    mode = "440";
    group = "influxdb2";
  };
  services.influxdb2.provision.organizations.machines.auths."grafana machines:telegraf (${config.node.name})" =
    {
      readBuckets = [ "telegraf" ];
      writeBuckets = [ "telegraf" ];
      tokenFile = config.age.secrets."grafana-influxdb-token-machines-${config.node.name}".path;
    };

  age.secrets."grafana-influxdb-token-home-${config.node.name}" = {
    inherit (config.age.secrets.grafana-influxdb-token-home) rekeyFile;
    mode = "440";
    group = "influxdb2";
  };

  services.influxdb2.provision.organizations.home.auths."grafana home:home_assistant (${config.node.name})" =
    {
      readBuckets = [ "home_assistant" ];
      writeBuckets = [ "home_assistant" ];
      tokenFile = config.age.secrets."grafana-influxdb-token-home-${config.node.name}".path;
    };
}
