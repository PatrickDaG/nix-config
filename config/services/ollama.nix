{config, ...}: {
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [config.services.open-webui.port];
  };
  networking.firewall.allowedTCPPorts = [config.services.open-webui.port];
  services.ollama = {
    host = "localhost";
    port = 3001;
    enable = true;
  };
  services.open-webui = {
    host = "0.0.0.0";
    port = 3000;
    enable = true;
    environment = {
      ENV = "prod";
      OLLAMA_BASE_URL = "http://localhost:3001";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      TRANSFORMERS_CACHE = "/var/lib/open-webui/cache/huggingface";
      WEBUI_AUTH_TRUSTED_EMAIL_HEADER = "X-Email";
      ENABLE_COMMUNITY_SHARING = "False";
      ENABLE_ADMIN_EXPORT = "False";

      WEBUI_AUTH = "False";
      ENABLE_SIGNUP = "False";
      DEFAULT_USER_ROLE = "user";
    };
  };
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/private/open-webui";
      mode = "0700";
    }
    {
      directory = "/var/lib/private/ollama";
      mode = "0700";
    }
  ];
}
