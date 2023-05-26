{
  nodeSecrets,
  nodePath,
  ...
}: {
  networking = {
    inherit (nodeSecrets.networking) hostId;
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
      matchConfig.MACAddress = nodeSecrets.networking.lan1.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      gateway = [nodeSecrets.networking.fuckKoreanDorm.gateway];
      address = [nodeSecrets.networking.fuckKoreanDorm.address];
      dns = ["9.9.9.9"];
    };
    "01-wlan1" = {
      DHCP = "yes";
      matchConfig.MACAddress = nodeSecrets.networking.wlan1.mac;
      networkConfig.IPv6PrivacyExtensions = "yes";
      # TODO: change dns to own when at hom
      dns = ["9.9.9.9"];
    };
  };
  rekey.secrets.eduroam = {
    file = nodePath + "/secrets/iwd/eduroam.8021x.age";
    path = "/var/lib/iwd/eduroam.8021x";
  };
  rekey.secrets.devoloog = {
    file = nodePath + "/secrets/iwd/devolo-og.psk.age";
    path = "/var/lib/iwd/devolo-og.psk";
  };
  rekey.secrets.kaist = {
    file = nodePath + "/secrets/iwd/kaist.8021x.age";
    path = "/var/lib/iwd/Welcome_KAIST.8021x";
  };
}
