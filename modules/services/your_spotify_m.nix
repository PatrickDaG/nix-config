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
    optional
    optionalAttrs
    types
    ;
  cfg = config.services.your_spotify;

  configEnv = concatMapAttrs (name: value:
    optionalAttrs (value != null) {
      name =
        if isBool value
        then boolToString value
        else toString value;
    })
  cfg.settings;

  configFile = pkgs.writeText "your_spotify.env" (concatStrings (mapAttrsToList (name: value: "${name}=${value}\n") configEnv));
in {
  options.services.your_spotify = let
    inherit (types) nullOr port str bool package;
  in {
    enable = mkEnableOption "your_spotify";

    enableLocalDB = mkEnableOption "a local mongodb instance";
    enableNginxVirtualHost = mkEnableOption "a ngnix virtual Host for your client";

    package = mkPackageOption pkgs "your_spotify" {};

    clientPackage = mkOption {
      type = package;
      default = cfg.package.client.override {apiEndpoint = cfg.settings.API_ENDPOINT;};
      description = "Client package to use.";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf types.str;
        options = {
          CLIENT_ENDPOINT = mkOption {
            type = str;
            description = "The endpoint of your web application";
            example = "https://your_spotify.example.org";
          };
          API_ENDPOINT = mkOption {
            type = str;
            description = ''
              The endpoint of your server
              This api has to be reachable from the device you use the website from not from the server.
              This means that for example you may need two nginx virtual hosts if you want to expose this on the
              internet.
            '';
            default = "http://localhost:8080";
          };
          spotifyPublic = mkOption {
            type = nullOr str;
            description = ''
              The public key of your Spotify application
              [Creating the Spotify Application](https://github.com/Yooooomi/your_spotify#creating-the-spotify-application)
            '';
            default = null;
          };
          spotifySecret = mkOption {
            type = nullOr str;
            description = ''
              The secret key of your Spotify application
              [Creating the Spotify Application](https://github.com/Yooooomi/your_spotify#creating-the-spotify-application)
              Note that you may want to set this using the `environmentFile` config option to prevent
              your secret from being world-readable in the nix store.
            '';
            default = null;
          };
          cors = mkOption {
            type = nullOr str;
            description = ''
              List of comma-separated origin allowed, or nothing to allow any origin
            '';
            default = null;
          };
          maxImportCacheSize = mkOption {
            type = str;
            description = ''
              The maximum element in the cache when importing data from an outside source,
              more cache means less requests to Spotify, resulting in faster imports
            '';
            default = "Infinite";
          };
          mongoEndpoint = mkOption {
            type = str;
            description = ''
              The endpoint of the Mongo database.
            '';
            default = "mongodb://localhost:27017/your_spotify";
          };
          port = mkOption {
            type = port;
            description = "The port of the api server";
            default = 8080;
          };
          timezone = mkOption {
            type = str;
            description = ''
              The timezone of your stats, only affects read requests since data is saved with UTC time
            '';
            default = "Europe/Paris";
          };
          logLevel = mkOption {
            type = str;
            description = ''
              The log level, debug is useful if you encouter any bugs
            '';
            default = "info";
          };
          cookieValidityMs = mkOption {
            type = str;
            description = ''
              Validity time of the authentication cookie
            '';
            default = "1h";
          };
          mongoNoAdminRights = mkOption {
            type = bool;
            description = ''
              Do not ask for admin right on the Mongo database
            '';
            default = false;
          };
        };
      };
    };

    environmentFile = mkOption {
      type = with types; nullOr path;
      default = null;
      example = "/var/lib/your_spotify.env";
      description = ''
        Additional environment file as defined in {manpage}`systemd.exec(5)`.

        Secrets like {env}`SPOTIFY_SECRET`
        may be passed to the service without adding them to the world-readable Nix store.

        Note that this file needs to be available on the host on which
        `your_spotify` is running.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.your_spotify = {
      after = ["network.target"];
      serviceConfig = {
        User = "your_spotify";
        Group = "your_spotify";
        DynamicUser = true;
        EnvironmentFile = [configFile] ++ optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStartPre = "${pkgs.your_spotify}/bin/your_spotify_migrate";
        ExecStart = "${pkgs.your_spotify}/bin/your_spotify_server";
        StateDirectory = "your_spotify";
        LimitNOFILE = "1048576";
        PrivateTmp = true;
        PrivateDevices = true;
        StateDirectoryMode = "0700";
        Restart = "always";

        # Hardening
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        DevicePolicy = "closed";
        SupplementaryGroups = ["dialout"];
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
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        #RestrictSUIDSGID = true; # Implied by DynamicUser
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "@mount" # Required by platformio for chroot
        ];
        UMask = "0077";
      };
      wantedBy = ["multi-user.target"];
    };
    services.nginx = mkIf cfg.enableNginxVirtualHost {
      enable = true;
      virtualHosts.${cfg.settings.CLIENT_ENDPOINT} = {
        locations."/".extraConfig = ''
          try_files = "$uri $uri/ /index.html;
        '';
      };
    };
    services.mongodb = mkIf cfg.enableLocalDB {
      enable = true;
    };
  };
}
# nginx gaten
# systemd hardening(e.g. esphome)

