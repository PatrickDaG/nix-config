# Auto-generated using compose2nix v0.1.6.
{
  pkgs,
  lib,
  config,
  ...
}: let
  version = "v1.93.3";
  immichDomain = "immich.${config.secrets.secrets.global.domains.web}";

  ipImmichMachineLearning = "10.89.0.10";
  ipImmichMicroservices = "10.89.0.11";
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
      machineLearning = {
        clip = {
          enabled = true;
          modelName = "ViT-B-32__openai";
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
      map = {
        enabled = true;
        darkStyle = "";
        lightStyle = "";
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
      thumbnail = {
        colorspace = "p3";
        jpegSize = 1440;
        quality = 80;
        webpSize = 250;
      };
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
    IMMICH_SERVER_URL = "http://${ipImmichServer}:3001/";
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
    after = [
      "podman-network-immich-default.service"
    ];
    requires = [
      "podman-network-immich-default.service"
    ];
    partOf = [
      "podman-compose-immich-root.target"
    ];
    wantedBy = [
      "podman-compose-immich-root.target"
    ];
  };
in {
  age.secrets.resticpasswd = {
    generator.script = "alnum";
  };
  age.secrets.immichHetznerSsh = {
    generator.script = "ssh-ed25519";
  };
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
        inherit (config.secrets.secrets.global.hetzner) mainUser;
        inherit (config.secrets.secrets.global.hetzner.users.immich) subUid path;
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
      pruneOpts = [
        "--keep-daily 10"
        "--keep-weekly 7"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
    };
  };
  microvm = {
    mem = 1024 * 8;
    vcpu = 12;
  };
  networking.firewall = {
    allowedTCPPorts = [2283];
    filterForward = true;
    extraForwardRules = ''
      ip saddr ${lib.net.cidr.host config.secrets.secrets.global.net.ips."elisabeth" config.secrets.secrets.global.net.privateSubnet} tcp dport 3001 accept
      iifname "podman1" oifname lan accept
    '';
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
      "${configFile}:${environment.IMMICH_CONFIG_FILE}:ro"
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

  virtualisation.oci-containers.containers."immich_microservices" = {
    image = "ghcr.io/immich-app/immich-server:${version}";
    inherit environment;
    volumes = [
      "${configFile}:${environment.IMMICH_CONFIG_FILE}:ro"
      "/etc/localtime:/etc/localtime:ro"
      "${upload_folder}:/usr/src/app/upload:rw"
      "${environment.DB_PASSWORD_FILE}:${environment.DB_PASSWORD_FILE}:ro"
    ];
    cmd = ["start.sh" "microservices"];
    dependsOn = [
      "immich_postgres"
      "immich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=immich-microservices"
      "--network=immich-default"
      "--ip=${ipImmichMicroservices}"
    ];
  };
  systemd.services."podman-immich_microservices" =
    serviceConfig
    // {
      unitConfig.UpheldBy = [
        "podman-immich_postgres.service"
        "podman-immich_redis.service"
      ];
    };

  virtualisation.oci-containers.containers."immich_postgres" = {
    image = "tensorchord/pgvecto-rs:pg14-v0.1.11@sha256:0335a1a22f8c5dd1b697f14f079934f5152eaaa216c09b61e293be285491f8ee";
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
    image = "redis:6.2-alpine@sha256:c5a607fb6e1bb15d32bbcf14db22787d19e428d59e31a5da67511b49bb0f1ccc";
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
      "${configFile}:${environment.IMMICH_CONFIG_FILE}:ro"
      "/etc/localtime:/etc/localtime:ro"
      "${upload_folder}:/usr/src/app/upload:rw"
      "${environment.DB_PASSWORD_FILE}:${environment.DB_PASSWORD_FILE}:ro"
    ];
    ports = [
      "2283:3001/tcp"
    ];
    cmd = ["start.sh" "immich"];
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
  systemd.services."podman-immich_server" =
    serviceConfig
    // {
      unitConfig.UpheldBy = [
        "podman-immich_postgres.service"
        "podman-immich_redis.service"
      ];
    };

  # Networks
  systemd.services."podman-network-immich-default" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f immich-default";
    };
    script = ''
      podman network inspect immich-default || podman network create immich-default --opt isolate=true --disable-dns --subnet=10.89.0.0/24
    '';
    partOf = ["podman-compose-immich-root.target"];
    wantedBy = ["podman-compose-immich-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-immich-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
