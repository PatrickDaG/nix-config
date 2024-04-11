{
  networking.firewall.allowedTCPPorts = [11434];
  services.ollama = {
    listenAddress = "0.0.0.0:11434";
    enable = true;
  };
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/private/ollama";
      mode = "0700";
    }
  ];
}
