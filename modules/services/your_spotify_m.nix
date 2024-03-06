{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    boolToString
    concatMapAttrs
    concatStrings
    isBool
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionalAttrs
    types
    ;
  cfg = config.services.your_spotify;

  configEnv = concatMapAttrs (name: value:
    optionalAttrs (value != null) {
      ${name} =
        if isBool value
        then boolToString value
        else toString value;
    })
  cfg.settings;

  configFile = pkgs.writeText "your_spotify.env" (concatStrings (mapAttrsToList (name: value: "${name}=${value}\n") configEnv));
in {
  options.services.your_spotify = let
    inherit (types) nullOr port str path bool package;
  in {
    enable = mkEnableOption "your_spotify";

    enableLocalDB = mkEnableOption "a local mongodb instance";
    nginxVirtualHost = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        If set creates an nginx virtual host for the client.
        In most cases this should be the CLIENT_ENDPOINT without
        protocol prefix.
      '';
    };

    package = mkPackageOption pkgs "your_spotify" {};

    clientPackage = mkOption {
      type = package;
      default = cfg.package.client.override {apiEndpoint = cfg.settings.API_ENDPOINT;};
      description = "Client package to use.";
    };
    spotifyPublicFile = mkOption {
      type = path;
      description = ''
        The public key of your Spotify application
        [Creating the Spotify Application](https://github.com/Yooooomi/your_spotify#creating-the-spotify-application)
      '';
    };

    spotifySecretFile = mkOption {
      type = path;
      description = ''
        The secret key of your Spotify application
        [Creating the Spotify Application](https://github.com/Yooooomi/your_spotify#creating-the-spotify-application)
        Note that you may want to set this using the `environmentFile` config option to prevent
        your secret from being world-readable in the nix store.
      '';
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf types.str;
        options = {
          CLIENT_ENDPOINT = mkOption {
            type = str;
            description = ''
              The endpoint of your web application
              Has to include a protocol Prefix (e.g. `http://`)
            '';
            example = "https://your_spotify.example.org";
          };
          API_ENDPOINT = mkOption {
            type = str;
            description = ''
              The endpoint of your server
              This api has to be reachable from the device you use the website from not from the server.
              This means that for example you may need two nginx virtual hosts if you want to expose this on the
              internet.
              Has to include a protocol Prefix (e.g. `http://`)
            '';
            default = "https://localhost:3000";
          };
          CORS = mkOption {
            type = nullOr str;
            description = ''
              List of comma-separated origin allowed, or nothing to allow any origin
            '';
            default = null;
          };
          MAX_IMPORT_CACHESIZE = mkOption {
            type = str;
            description = ''
              The maximum element in the cache when importing data from an outside source,
              more cache means less requests to Spotify, resulting in faster imports
            '';
            default = "Infinite";
          };
          MONGO_ENDPOINT = mkOption {
            type = str;
            description = ''
              The endpoint of the Mongo database.
            '';
            default = "mongodb://localhost:27017/your_spotify";
          };
          PORT = mkOption {
            type = port;
            description = "The port of the api server";
            default = 3000;
          };
          TIMEZONE = mkOption {
            type = str;
            description = ''
              The timezone of your stats, only affects read requests since data is saved with UTC time
            '';
            default = "Europe/Paris";
          };
          LOG_LEVEL = mkOption {
            type = str;
            description = ''
              The log level, debug is useful if you encouter any bugs
            '';
            default = "info";
          };
          COOKIE_VALIDITY_MS = mkOption {
            type = str;
            description = ''
              Validity time of the authentication cookie
            '';
            default = "1h";
          };
          MONGO_NO_ADMIN_RIGHTS = mkOption {
            type = bool;
            description = ''
              Do not ask for admin right on the Mongo database
            '';
            default = false;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.your_spotify = {
      after = ["network.target"];
      script = ''
        export SPOTIFY_PUBLIC=$(< "$CREDENTIALS_DIRECTORY/SPOTIFY_PUBLIC")
        export SPOTIFY_SECRET=$(< "$CREDENTIALS_DIRECTORY/SPOTIFY_SECRET")
        ${pkgs.your_spotify}/bin/your_spotify_migrate
        exec ${pkgs.your_spotify}/bin/your_spotify_server
      '';
      serviceConfig = {
        User = "your_spotify";
        Group = "your_spotify";
        DynamicUser = true;
        EnvironmentFile = [configFile];
        StateDirectory = "your_spotify";
        LimitNOFILE = "1048576";
        PrivateTmp = true;
        PrivateDevices = true;
        StateDirectoryMode = "0700";
        Restart = "always";

        LoadCredential = ["SPOTIFY_PUBLIC:${cfg.spotifyPublicFile}" "SPOTIFY_SECRET:${cfg.spotifySecretFile}"];

        # Hardening
        CapabilityBoundingSet = "";
        LockPersonality = true;
        #MemoryDenyWriteExecute = true;
        #NoNewPrivileges = true; # Implied by DynamicUser
        PrivateUsers = true;
        #PrivateTmp = true; # Implied by DynamicUser
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = false; # breaks bwrap
        ProtectKernelLogs = false; # breaks bwrap
        ProtectKernelModules = true;
        ProtectKernelTunables = false; # breaks bwrap
        ProtectProc = "invisible";
        ProcSubset = "all"; # Using "pid" breaks bwrap
        ProtectSystem = "strict";
        #RemoveIPC = true; # Implied by DynamicUser
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        #RestrictSUIDSGID = true; # Implied by DynamicUser
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "@pkey"
        ];
        UMask = "0077";
      };
      wantedBy = ["multi-user.target"];
    };
    services.nginx = mkIf (cfg.nginxVirtualHost != null) {
      enable = true;
      virtualHosts.${cfg.nginxVirtualHost} = {
        root = cfg.clientPackage;
        locations."/".extraConfig = ''
          try_files = $uri $uri/ /index.html ;
        '';
      };
    };
    services.mongodb = mkIf cfg.enableLocalDB {
      enable = true;
    };
  };
}
