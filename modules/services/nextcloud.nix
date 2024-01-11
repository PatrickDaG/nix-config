{
  lib,
  pkgs,
  config,
  ...
}: let
  hostName = "nc.${config.secrets.secrets.global.domains.web}";
in {
  systemd.network.networks = {
    "TODO" = {
      address = ["192.168.178.33/24"];
      gateway = ["192.168.178.1"];
      matchConfig.Name = "lan01*";
      dns = ["192.168.178.2"];
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        MulticastDNS = true;
      };
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/postgresql/";
      user = "postgres";
      group = "postgres";
      mode = "750";
    }
  ];
  environment.persistence."/panzer".directories = [
    {
      directory = config.services.nextcloud.home;
      user = "nextcloud";
      group = "nextcloud";
      mode = "750";
    }
  ];
  age.secrets.ncpasswd = {
    generator.script = "alnum";
    mode = "440";
    owner = "nextcloud";
  };
  services.postgresql.package = pkgs.postgresql_16;
  services.nginx.virtualHosts.${hostName}.extraConfig = ''
    allow TODO;
    deny all;
  '';

  services.nextcloud = {
    inherit hostName;
    enable = true;
    package = pkgs.nextcloud28;
    configureRedis = true;
    config.adminpassFile = config.age.secrets.ncpasswd.path; # Kinda ok just remember to instanly change after first setup
    config.adminuser = "admin";
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit contacts calendar tasks notes maps phonetrack;
    };
    maxUploadSize = "4G";
    extraAppsEnable = true;
    database.createLocally = true;
    phpOptions."opcache.interned_strings_buffer" = "32";
    extraOptions = {
      default_phone_region = "DE";
      trusted_proxies = ["TODO"];
      overwriteprotocol = "https";
      enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
      ];
    };
    config = {
      dbtype = "pgsql";
    };
  };

  networking = {
    firewall.allowedTCPPorts = [80];
    # Use systemd-resolved inside the container
    useHostResolvConf = lib.mkForce false;
  };

  services.resolved.enable = true;
}
