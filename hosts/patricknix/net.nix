{
  nodePath,
  config,
  ...
}: {
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
    wireless.iwd.enable = true;
    # Add the VPN based route to my paperless instance to
    # etc/hosts
    extraHosts = ''
      10.0.0.1 paperless.lel.lol
    '';
  };

  systemd.network.networks = {
    "01-lan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.lan1.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      dns = ["9.9.9.9"];
    };
    "01-wlan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.wlan1.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      # TODO: change dns to own when at home
      dns = ["9.9.9.9"];
    };
  };
  age.secrets.eduroam = {
    rekeyFile = nodePath + "/secrets/iwd/eduroam.8021x.age";
    path = "/var/lib/iwd/eduroam.8021x";
  };
  age.secrets.devoloog = {
    rekeyFile = nodePath + "/secrets/iwd/devolo-og.psk.age";
    path = "/var/lib/iwd/devolo-og.psk";
  };
}
