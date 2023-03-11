{
  networking.wireless.iwd.enable = true;
  rekey.secrets.eduroam = {
    file = ../secrets/iwd/eduroam.8021x.age;
    path = "/var/lib/iwd/eduroam.8021x";
  };
  rekey.secrets.devoloog = {
    file = ../secrets/iwd/devolo-og.psk.age;
    path = "/var/lib/iwd/devolo-og.psk";
  };
  rekey.secrets.kaist = {
    file = ../secrets/iwd/kaist.8021x.age;
    path = "/var/lib/iwd/Welcome_KAIST.8021x";
  };

  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  # Should remain enabled since nscd from glibc is kinda ass
  services.nscd.enableNsncd = true;
  systemd.network.wait-online.anyInterface = true;
  # Fuck korea.
  # I need a static global IP address for my dorm LAN
  # So to not dox myself this config file is hardcoded
  rekey.secrets.enp0s20f0u2u4 = {
    file = ../secrets/koreaIP.age;
    path = "/etc/systemd/network/10-enp0s20f0u2u4.network";
    mode = "444";
  };
  services.resolved = {
    enable = true;
  };
  # Add the VPN based route to my paperless instance to
  # etc/hosts
  networking.extraHosts = ''
    10.0.0.1 paperless.lel.lol
  '';

  networking.firewall.enable = false;
}
