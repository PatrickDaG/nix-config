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
    elem
    foldl'
    head
    isBool
    isList
    lowerChars
    mapAttrsToList
    mdDoc
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    optionalAttrs
    optionalString
    stringLength
    substring
    toUpper
    types
    ;
  cfg = config.services.your_spotify;

  # Convert name from camel case (e.g. disable2FARemember) to upper case snake case (e.g. DISABLE_2FA_REMEMBER).
  nameToEnvVar = name: let
    parts = builtins.split "([A-Z0-9]+)" name;
    partsToEnvVar = parts:
      foldl' (key: x: let
        last = stringLength key - 1;
      in
        if isList x
        then key + optionalString (key != "" && substring last 1 key != "_") "_" + head x
        else if key != "" && elem (substring 0 1 x) lowerChars
        then # to handle e.g. [ "disable" [ "2FAR" ] "emember" ]
          substring 0 last key + optionalString (substring (last - 1) 1 key != "_") "_" + substring last 1 key + toUpper x
        else key + toUpper x) ""
      parts;
  in
    if builtins.match "[A-Z0-9_]+" name != null
    then name
    else partsToEnvVar parts;

  # Due to the different naming schemes allowed for config keys,
  # we can only check for values consistently after converting them to their corresponding environment variable name.
  configEnv = concatMapAttrs (name: value:
    optionalAttrs (value != null) {
      ${nameToEnvVar name} =
        if isBool value
        then boolToString value
        else toString value;
    })
  cfg.config;

  configFile = pkgs.writeText "your_spotify.env" (concatStrings (mapAttrsToList (name: value: "${name}=${value}\n") configEnv));
in {
  options.services.your_spotify = let
    inherit (types) nullOr int str bool package;
  in {
    enable = mkEnableOption (lib.mdDoc "your_spotify");
    user = mkOption {
      type = types.str;
      default = "your_spotify";
      description = lib.mdDoc "User account under which your_spotify runs.";
    };

    group = mkOption {
      type = types.str;
      default = "your_spotify";
      description = lib.mdDoc "Group account under which your_spotify runs.";
    };

    package = mkPackageOption pkgs "your_spotify" {};

    clientPackage = mkOption {
      type = package;
      default = cfg.package.client.override {apiEndpoint = cfg.config.apiEndpoint;};
      description = lib.mdDoc "Client package to use.";
    };

    config = {
      clientEndpoint = mkOption {
        type = str;
        description = "The endpoint of your web application";
        example = "https://your_spotify.example.org";
      };
      apiEndpoint = mkOption {
        type = str;
        description = "The endpoint of your server";
        default = "http://localhost:8080";
      };
      spotifyPublic = mkOption {
        type = nullOr str;
        description = mdDoc ''
          The public key of your Spotify application
          [Creating the Spotify Application](https://github.com/Yooooomi/your_spotify#creating-the-spotify-application)
        '';
        default = null;
      };
      spotifySecret = mkOption {
        type = nullOr str;
        description = mdDoc ''
          The secret key of your Spotify application
          [Creating the Spotify Application](https://github.com/Yooooomi/your_spotify#creating-the-spotify-application)
          Note that you may want to set this using the `environmentFile` config option to prevent
          your secret from being world-readable in the nix store.
        '';
        default = null;
      };
      cors = mkOption {
        type = nullOr str;
        description = mdDoc ''
          List of comma-separated origin allowed, or nothing to allow any origin
        '';
        default = null;
      };
      maxImportCacheSize = mkOption {
        type = str;
        description = mdDoc ''
          The maximum element in the cache when importing data from an outside source,
          more cache means less requests to Spotify, resulting in faster imports
        '';
        default = "Infinite";
      };
      mongoEndpoint = mkOption {
        type = str;
        description = mdDoc ''
          The endpoint of the Mongo database.
        '';
        default = "mongodb://localhost:27017/your_spotify";
      };
      port = mkOption {
        type = int;
        description = "The port of the server";
        default = 8080;
      };
      timezone = mkOption {
        type = str;
        description = mdDoc ''
          The timezone of your stats, only affects read requests since data is saved with UTC time
        '';
        default = "Europe/Paris";
      };
      logLevel = mkOption {
        type = str;
        description = mdDoc ''
          The log level, debug is useful if you encouter any bugs
        '';
        default = "info";
      };
      cookieValidityMs = mkOption {
        type = str;
        description = mdDoc ''
          Validity time of the authentication cookie
        '';
        default = "1h";
      };
      mongoNoAdminRights = mkOption {
        type = bool;
        description = mdDoc ''
          Do not ask for admin right on the Mongo database
        '';
        default = true;
      };
    };

    environmentFile = mkOption {
      type = with types; nullOr path;
      default = null;
      example = "/var/lib/your_spotify.env";
      description = lib.mdDoc ''
        Additional environment file as defined in {manpage}`systemd.exec(5)`.

        Secrets like {env}`SPOTIFY_SECRET`
        may be passed to the service without adding them to the world-readable Nix store.

        Note that this file needs to be available on the host on which
        `your_spotify` is running.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = {};

    systemd.services.your_spotify = {
      after = ["network.target"];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = [configFile] ++ optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStartPre = "${pkgs.your_spotify}/bin/your_spotify_migrate";
        ExecStart = "${pkgs.your_spotify}/bin/your_spotify_server";
        LimitNOFILE = "1048576";
        PrivateTmp = "true";
        PrivateDevices = "true";
        ProtectHome = "true";
        ProtectSystem = "strict";
        StateDirectory = "your_spotify";
        StateDirectoryMode = "0700";
        Restart = "always";
      };
      wantedBy = ["multi-user.target"];
    };
    services.mongodb.enable = true;
  };
}
