{
  config,
  globals,
  nodes,
  pkgs,
  ...
}:
{
  globals.services.linkwarden.host = config.node.name;
  age.secrets.linkwarden-nextauth-secret = {
    rekeyFile = config.node.secretsDir + "/linkwarden-nextauth-secret.age";
    generator.script = "base64";
    mode = "440";
    group = "linkwarden";
  };
  age.secrets.linkwarden-meilisearch-master-key = {
    generator.script = "base64";
    mode = "440";
    group = "linkwarden";
  };

  # Mirror the original oauth2 secret
  age.secrets.linkwarden-oauth2-client-secret = {
    inherit (nodes.${globals.services.kanidm.host}.config.age.secrets.oauth2-linkwarden) rekeyFile;
    mode = "440";
    group = "linkwarden";
  };

  globals.wireguard.services.hosts.${config.node.name}.firewallRuleForNode.elisabeth-nginx.allowedTCPPorts =
    [ 3003 ];
  # globals.wireguard.services-extern.hosts.${config.node.name}.firewallRuleForNode.torweg.allowedTCPPorts =
  #   [ 3003 ];

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/meilisearch";
      mode = "0700";
    }
    {
      directory = "/var/lib/private/ollama";
      mode = "0700";
    }
    {
      directory = "/var/lib/linkwarden";
      user = "linkwarden";
      group = "linkwarden";
      mode = "0750";
    }
    {
      directory = "/var/lib/postgresql";
      user = "postgres";
      group = "postgres";
    }
  ];

  services.meilisearch = {
    enable = true;
    listenAddress = "127.0.0.1";
    listenPort = 7700;
    masterKeyFile = config.age.secrets.linkwarden-meilisearch-master-key.path;
  };

  systemd.services.meilisearch.serviceConfig = {
    MemoryHigh = "2G";
    MemoryMax = "4G";
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cpu;
    host = "127.0.0.1";
    port = 11434;
    loadModels = [ "qwen3.5:4b" ];
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "4096";
      OLLAMA_KEEP_ALIVE = "1m";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_NUM_PARALLEL = "1";
    };
  };

  systemd.services.ollama.serviceConfig = {
    CPUWeight = 20;
    MemoryHigh = "6G";
    MemoryMax = "8G";
    Nice = 10;
  };

  services.linkwarden = {
    enable = true;
    host = "0.0.0.0";
    port = 3003;
    database.createLocally = true;
    enableRegistration = false;

    secretFiles.NEXTAUTH_SECRET = config.age.secrets.linkwarden-nextauth-secret.path;
    secretFiles.AUTHENTIK_CLIENT_SECRET = config.age.secrets.linkwarden-oauth2-client-secret.path;
    secretFiles.MEILI_MASTER_KEY = config.age.secrets.linkwarden-meilisearch-master-key.path;

    # NOTE: Well yes - it does not support generic OIDC so we piggyback on the AUTHENTIK provider
    environment = rec {
      RE_ARCHIVE_LIMIT = "0";
      MEILI_HOST = "http://127.0.0.1:7700";
      NEXTAUTH_URL = "https://${globals.services.linkwarden.domain}/api/v1/auth";
      NEXT_PUBLIC_OLLAMA_ENDPOINT_URL = "http://127.0.0.1:11434";
      OLLAMA_MODEL = "qwen3.5:4b";
      NEXT_PUBLIC_CREDENTIALS_ENABLED = "false"; # disables username / pass authentication
      NEXT_PUBLIC_AUTHENTIK_ENABLED = "true";
      NEXT_PUBLIC_MAX_FILE_BUFFER = "100"; # in MB
      AUTHENTIK_ISSUER = "https://${globals.services.kanidm.domain}/oauth2/openid/${AUTHENTIK_CLIENT_ID}";
      AUTHENTIK_CLIENT_ID = "linkwarden";
      AUTHENTIK_CUSTOM_NAME = "Kanidm (SSO)";
    };
  };

  systemd.services.linkwarden-worker = {
    after = [ "meilisearch.service" ];
    wants = [ "meilisearch.service" ];
  };

  # backups.storageBoxes.main = {
  #   subuser = "linkwarden";
  #   paths = [ "/var/lib/linkwarden" ];
  #   withPostgres = true;
  # };
}
