# Auto-generated using compose2nix v0.1.6.
{
  pkgs,
  nodes,
  config,
  globals,
  ...
}:
let
  version = "v1.119.1";
  immichDomain = "immich.${globals.domains.web}";

  ipImmichMachineLearning = "10.89.0.10";
  ipImmichPostgres = "10.89.0.12";
  ipImmichRedis = "10.89.0.13";
  ipImmichServer = "10.89.0.14";

  configFile = pkgs.writeText "immich.config.json" (
    builtins.toJSON {
      ffmpeg = {
        accel = "disabled";
        bframes = -1;
        cqMode = "auto";
        crf = 23;
        gopSize = 0;
        maxBitrate = "0";
        npl = 0;
        preset = "ultrafast";
        refs = 0;
        targetAudioCodec = "aac";
        targetResolution = "720";
        targetVideoCodec = "h264";
        temporalAQ = false;
        threads = 0;
        tonemap = "hable";
        transcode = "required";
        twoPass = false;
      };
      job = {
        backgroundTask.concurrency = 5;
        faceDetection.concurrency = 10;
        library.concurrency = 5;
        metadataExtraction.concurrency = 10;
        migration.concurrency = 5;
        search.concurrency = 5;
        sidecar.concurrency = 5;
        smartSearch.concurrency = 10;
        thumbnailGeneration.concurrency = 10;
        videoConversion.concurrency = 5;
      };
      library.scan = {
        enabled = true;
        cronExpression = "0 0 * * *";
      };
      logging = {
        enabled = true;
        level = "log";
      };
      notifications.smtp = {
        enabled = true;
        from = "immich@${globals.domains.mail_public}";
        transport = {
          username = "immich@${globals.domains.mail_public}";
          host = "smtp.${globals.domains.mail_public}";
          port = 465;
        };
      };
      machineLearning = {
        clip = {
          enabled = true;
          modelName = "ViT-B-16-SigLIP-384__webli";
        };
        enabled = true;
        facialRecognition = {
          enabled = true;
          maxDistance = 0.45;
          minFaces = 2;
          minScore = 0.65;
          modelName = "buffalo_l";
        };
        url = "http://${ipImmichMachineLearning}:3003";
      };
      # XXX: Immich's oauth cannot use PKCE and uses legacy crypto so we need to enable legacy crypto
      oauth = rec {
        enabled = true;
        autoLaunch = false;
        autoRegister = true;
        buttonText = "Login with Kanidm";

        mobileOverrideEnabled = true;
        mobileRedirectUri = "https://${immichDomain}/api/oauth/mobile-redirect";

        clientId = "immich";
        # clientSecret will be dynamically added in activation script
        issuerUrl = "https://auth.${globals.domains.web}/oauth2/openid/${clientId}";
        scope = "openid email profile";
        storageLabelClaim = "preferred_username";
      };
      map = {
        enabled = true;
      };
      newVersionCheck.enabled = true;
      passwordLogin.enabled = true;
      reverseGeocoding.enabled = true;
      server = {
        externalDomain = "https://${immichDomain}";
        loginPageMessage = "Wilkommen in Patricks tollem bilderparadies";
      };
      storageTemplate = {
        enabled = true;
        hashVerificationEnabled = true;
        template = "{{y}}/{{MM}}/{{filename}}";
      };
      theme.customCss = "";
      trash = {
        days = 30;
        enabled = true;
      };
    }
  );

  environment = {
    DB_DATABASE_NAME = "immich";
    DB_HOSTNAME = ipImmichPostgres;
    DB_PASSWORD_FILE = config.age.secrets.postgrespasswd.path;
    DB_USERNAME = "postgres";
    IMMICH_VERSION = "${version}";
    UPLOAD_LOCATION = upload_folder;
    IMMICH_SERVER_URL = "http://${ipImmichServer}:2283/";
    IMMICH_MACHINE_LEARNING_URL = "http://${ipImmichMachineLearning}:3003";
    REDIS_HOSTNAME = ipImmichRedis;
    IMMICH_CONFIG_FILE = "/immich.config.json";
  };
  upload_folder = "/panzer/immich";
  pgdata_folder = "/persist/immich/pgdata";
  model_folder = "/state/immich/modeldata";

  serviceConfig = {
    serviceConfig = {
      Restart = "always";
    };
    after = [ "podman-network-immich-default.service" ];
    requires = [ "podman-network-immich-default.service" ];
    partOf = [ "podman-compose-immich-root.target" ];
    wantedBy = [ "podman-compose-immich-root.target" ];
  };
  processedConfigFile = "/run/agenix/immich.config.json";
in
{
  age.secrets.mailnix-passwd = {
    generator.script = "alnum";
    group = "root";
  };

  age.secrets.mailnix-passwd-hash = {
    generator.dependencies = [ config.age.secrets.mailnix-passwd ];
    generator.script = "argon2id";
    mode = "440";
    intermediary = true;
  };
  nodes.mailnix = {
    age.secrets.idmail-immich-passwd-hash = {
      inherit (config.age.secrets.mailnix-passwd-hash) rekeyFile;
      group = "stalwart-mail";
      mode = "440";
    };
    services.idmail.provision.mailboxes."immich@${globals.domains.mail_public}" = {
      password_hash = "%{file:${nodes.mailnix.config.age.secrets.idmail-immich-passwd-hash.path}}%";
      owner = "admin";
    };
  };

  age.secrets.resticpasswd = {
    generator.script = "alnum";
  };
  age.secrets.immichHetznerSsh = {
    generator.script = "ssh-ed25519";
  };
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/containers";
      mode = "0755";
    }
  ];
  services.restic.backups = {
    main = {
      user = "root";
      timerConfig = {
        OnCalendar = "06:00";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
      initialize = true;
      passwordFile = config.age.secrets.resticpasswd.path;
      hetznerStorageBox = {
        enable = true;
        inherit (globals.hetzner) mainUser;
        inherit (globals.hetzner.users.immich) subUid path;
        sshAgeSecret = "immichHetznerSsh";
      };
      backupPrepareCommand = ''
        ${pkgs.podman}/bin/podman exec -t immich_postgres pg_dumpall -c -U postgres > /run/immich_dump.sql
      '';
      paths = [
        "${upload_folder}/library"
        "${upload_folder}/upload"
        "${upload_folder}/profile"
        "/run/immich_dump.sql"
      ];
      #pruneOpts = [
      #  "--keep-daily 10"
      #  "--keep-weekly 7"
      #  "--keep-monthly 12"
      #  "--keep-yearly 75"
      #];
    };
  };

  # Mirror the original oauth2 secret
  age.secrets.immich-oauth2-client-secret = {
    inherit (nodes.elisabeth-kanidm.config.age.secrets.oauth2-immich) rekeyFile;
    mode = "440";
    group = "root";
  };

  system.activationScripts.agenixRooterDerivedSecrets = {
    # Run after agenix has generated secrets
    deps = [ "agenix" ];
    text = ''
      immichClientSecret=$(< ${config.age.secrets.immich-oauth2-client-secret.path})
      immichEmailSecret=$(< ${config.age.secrets.mailnix-passwd.path})
      ${pkgs.jq}/bin/jq \
        --arg immichClientSecret "$immichClientSecret" \
        --arg immichEmailSecret "$immichEmailSecret" \
        '.oauth.clientSecret = $immichClientSecret | .notifications.smtp.transport.password = $immichEmailSecret' \
        ${configFile} > ${processedConfigFile}
      chmod 444 ${processedConfigFile}
    '';
  };

  microvm = {
    mem = 1024 * 8;
    vcpu = 12;
  };

  wireguard.services = {
    client.via = "nucnix";
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 3000 ];
  };

  networking.nftables.chains.forward.into-immich-container = {
    after = [ "conntrack" ];
    rules = [
      "iifname services ip saddr ${nodes.nucnix-nginx.config.wireguard.services.ipv4} tcp dport 2283 accept"
      "iifname podman1 oifname lan-services accept"
    ];
  };
  systemd.tmpfiles.settings = {
    "10-immich" = {
      ${upload_folder}.d = {
        mode = "0770";
      };
      ${pgdata_folder}.d = {
        mode = "0770";
      };
      ${model_folder}.d = {
        mode = "0770";
      };
    };
  };
  age.secrets.postgrespasswd = {
    generator.script = "alnum";
  };
  age.secrets.redispasswd = {
    generator.script = "alnum";
  };
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };
  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."immich_machine_learning" = {
    image = "ghcr.io/immich-app/immich-machine-learning:${version}";
    inherit environment;
    volumes = [
      "${processedConfigFile}:${environment.IMMICH_CONFIG_FILE}:ro"
      "${model_folder}:/cache:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=immich-machine-learning"
      "--network=immich-default"
      "--ip=${ipImmichMachineLearning}"
    ];
  };
  systemd.services."podman-immich_machine_learning" = serviceConfig;

  virtualisation.oci-containers.containers."immich_postgres" = {
    image = "tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
    environment = {
      POSTGRES_DB = environment.DB_DATABASE_NAME;
      POSTGRES_PASSWORD_FILE = environment.DB_PASSWORD_FILE;
      POSTGRES_USER = environment.DB_USERNAME;
    };
    volumes = [
      "${pgdata_folder}:/var/lib/postgresql/data:rw"
      "${environment.DB_PASSWORD_FILE}:${environment.DB_PASSWORD_FILE}:ro"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=immich_postgres"
      "--network=immich-default"
      "--ip=${ipImmichPostgres}"
    ];
  };
  systemd.services."podman-immich_postgres" = serviceConfig;
  virtualisation.oci-containers.containers."immich_redis" = {
    image = "redis:6.2-alpine@sha256:51d6c56749a4243096327e3fb964a48ed92254357108449cb6e23999c37773c5";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=immich_redis"
      "--network=immich-default"
      "--ip=${ipImmichRedis}"
    ];
  };
  systemd.services."podman-immich_redis" = serviceConfig;
  virtualisation.oci-containers.containers."immich_server" = {
    image = "ghcr.io/immich-app/immich-server:${version}";
    inherit environment;
    volumes = [
      "${processedConfigFile}:${environment.IMMICH_CONFIG_FILE}:ro"
      "/etc/localtime:/etc/localtime:ro"
      "${upload_folder}:/usr/src/app/upload:rw"
      "${environment.DB_PASSWORD_FILE}:${environment.DB_PASSWORD_FILE}:ro"
    ];
    ports = [ "3000:2283/tcp" ];
    dependsOn = [
      "immich_postgres"
      "immich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=immich-server"
      "--network=immich-default"
      "--ip=${ipImmichServer}"
    ];
  };
  systemd.services."podman-immich_server" = serviceConfig // {
    unitConfig.UpheldBy = [
      "podman-immich_postgres.service"
      "podman-immich_redis.service"
    ];
  };

  # Networks
  systemd.services."podman-network-immich-default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f immich-default";
    };
    script = ''
      podman network inspect immich-default || podman network create immich-default --opt isolate=true --disable-dns --subnet=10.89.0.0/24
    '';
    partOf = [ "podman-compose-immich-root.target" ];
    wantedBy = [ "podman-compose-immich-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-immich-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
