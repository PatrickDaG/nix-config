{
  config,
  pkgs,
  globals,
  ...
}:
{
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  systemd.network.networks = {
    "01-lan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
      };
    };
    "01-wlan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.wlan01.mac;
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
      };
    };
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [ "lan01" ];
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  environment.persistence."/state".directories = [
    "/etc/mullvad-vpn"
    # {
    #   directory = "/var/lib/netbird-main";
    #   user = "netbird-main";
    #   group = "netbird-main";
    #   mode = "770";
    # }
    {
      directory = "/var/lib/tailscale";
      mode = "750";
    }
  ];
  # services.netbird = {
  #   ui.enable = false;
  #   clients.main = {
  #     port = 51820;
  #     environment = {
  #       NB_MANAGEMENT_URL = "https://netbird.${globals.domains.web}";
  #       NB_ADMIN_URL = "https://netbird.${globals.domains.web}";
  #       NB_HOSTNAME = "desktopnix";
  #       # TODO remove once netbird client is merged
  #       NB_STATE_DIR = "/var/lib/netbird-main";
  #     };
  #   };
  # };
  # users.users."patrick".extraGroups = [ "netbird-main" ];
  meta.telegraf.availableMonitoringNetworks = [
    "home"
  ];
  # generated using
  # 'headscale preauthkeys create -e 99y --reusable -u 1 --tags "tag:server"'
  age.secrets.authKeyFile = {
    rekeyFile = config.node.secretsDir + "/authkey.age";
  };
  services.tailscale = {
    enable = true;
    extraDaemonFlags = [ "--no-logs-no-support" ];
    disableTaildrop = true;
    authKeyFile = config.age.secrets.authKeyFile.path;
    # These get applied everytime
    extraSetFlags = [
      "--accept-dns"
      "--accept-routes"
      "--shields-up"
      "--operator=patrick"
    ];
    # These only on reauth
    extraUpFlags = [
      "--login-server=${"https://${globals.services.headscale.domain}"}"
    ];
  };
}
