{
  nodes,
  config,
  globals,
  lib,
  ...
}:
let
  immichDomain = "immich.${globals.domains.web}";
  mediaLocation = "/panzer/immich";
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

  # Mirror the original oauth2 secret.
  age.secrets.immich-oauth2-client-secret = {
    inherit (nodes.${globals.services.kanidm.host}.config.age.secrets.oauth2-immich) rekeyFile;
    mode = "440";
    group = "root";
  };

  environment.persistence = {
    "/persist".directories = [
      {
        directory = "/var/lib/postgresql";
        user = "postgres";
        group = "postgres";
        mode = "0750";
      }
    ];
    "/state".directories = [
      {
        directory = "/var/cache/immich";
        user = "immich";
        group = "immich";
        mode = "0700";
      }
    ];
  };

  backups.storageBoxes.main = {
    subuser = "immich";
    paths = [ mediaLocation ];
    withPostgres = true;
  };

  services.immich = {
    enable = true;
    host = "";
    port = 3000;
    inherit mediaLocation;

    settings = {
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
          password._secret = config.age.secrets.mailnix-passwd.path;
        };
      };
      machineLearning = {
        clip = {
          enabled = true;
          modelName = "ViT-SO400M-16-SigLIP2-384__webli";
        };
        enabled = true;
        facialRecognition = {
          enabled = true;
          maxDistance = 0.45;
          minFaces = 2;
          minScore = 0.65;
          modelName = "antelopev2";
        };
        url = "http://localhost:3003";
      };
      # Immich cannot use PKCE, so Kanidm permits its legacy OAuth flow.
      oauth = rec {
        enabled = true;
        autoLaunch = false;
        autoRegister = true;
        buttonText = "Login with Kanidm";

        mobileOverrideEnabled = true;
        mobileRedirectUri = "https://${immichDomain}/api/oauth/mobile-redirect";

        clientId = "immich";
        clientSecret._secret = config.age.secrets.immich-oauth2-client-secret.path;
        issuerUrl = "https://auth.${globals.domains.web}/oauth2/openid/${clientId}";
        scope = "openid email profile";
        storageLabelClaim = "preferred_username";
      };
      map.enabled = true;
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
    };
  };

  # Migration guard: remove after restoring the exported database.
  systemd.services.immich-server.wantedBy = lib.mkForce [ ];

  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.elisabeth-nginx.allowedTCPPorts = [ config.services.immich.port ];
  };

  systemd.tmpfiles.settings."10-immich".${mediaLocation}.d = {
    user = "immich";
    group = "immich";
    mode = "0770";
  };
}
