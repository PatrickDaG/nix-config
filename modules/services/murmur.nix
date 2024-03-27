{config, ...}: {
  services.murmur = {
    enable = true;
    welcometext = ''
      hurensohn
    '';
    registerHostname = "mumble.${config.secrets.secrets.global.domains.web}";
    registerName = "patrick ist der tollste";
    inherit (config.secrets.secrets.local) password;
    openFirewall = true;
  };
}
