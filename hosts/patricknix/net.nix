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

  # Fuck korea.
  # I need a static global IP address for my dorm LAN
  # So to not dox myself this config file is hardcoded
  systemd.network.networks = {
    "01-lan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.lan1.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      gateway = [config.secrets.secrets.local.networking.fuckKoreanDorm.gateway];
      address = [config.secrets.secrets.local.networking.fuckKoreanDorm.address];
      dns = ["9.9.9.9"];
    };
    "01-wlan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = config.secrets.secrets.local.networking.wlan1.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      # TODO: change dns to own when at hom
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
  age.secrets.kaist = {
    rekeyFile = nodePath + "/secrets/iwd/kaist.8021x.age";
    path = "/var/lib/iwd/Welcome_KAIST.8021x";
  };
}
