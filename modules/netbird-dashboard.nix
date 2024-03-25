{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkPackageOption
    mkIf
    mkEnableOption
    mkOption
    types
    isBool
    boolToString
    ;

  toStringEnv = value:
    if isBool value
    then boolToString value
    else toString value;
  cfg = config.services.netbird-dashboard;
in {
  options.services.netbird-dashboard = {
    enable = mkEnableOption "the static netbird dashboard frontend";
    package = mkPackageOption pkgs "netbird-dashboard" {};
    enableNginx = mkEnableOption "Nginx as a webserver serving the backend";
    domain = mkOption {
      type = types.str;
      description = "The domain under which the dashboard runs.";
      default = "localhost";
    };
    settings = mkOption {
      description = ''
        An attr set that will be used as environment to build the dashboard.
        Any values that you set here will be templated into the frontend
        and thas be freely available for anyone that can reach your website.
        The exact values sadly aren't documented anywhere. An starting point
        when searching for valid values is this [script](https://github.com/netbirdio/dashboard/blob/main/docker/init_react_envs.sh)
        The only mandatory value is 'AUTH_AUTHORITY' as we cannot set a default value here.
      '';
      type = types.submodule {
        freeformType = types.attrsOf (types.oneOf [types.str types.bool]);
        config = {
          # Due to how the backend and frontend work this secret will be templated into the backend
          # and then served statically from your website
          # This enables you to login without the normally needed indirection through the backend
          # but this also means anyone that can reach your website can
          # fetch this secret, which is why there is no real need to put it into
          # special options as its public anyway
          # As far as I know leaking this secret is just
          # an information leak as one can fetch some basic app
          # informations from the IDP
          # To actually do something one still needs to have login
          # data and this secret so this being public will not
          # suffice for anything just decreasing security
          AUTH_CLIENT_SECRET = "";
          AUTH_CLIENT_ID = "netbird";
          # AUTH_AUDIENCE must be set for your devices to be able to log in
          AUTH_AUDIENCE = "netbird";
          USE_AUTH0 = false;
          AUTH_SUPPORTED_SCOPES = "openid profile email";

          # While you could override this to use http I would recommend to not do that
          # as it will greatly impact the security of your application
          NETBIRD_MGMT_API_ENDPOINT = "https://${config.services.netbird-server.domain}";
          NETBIRD_MGMT_GRPC_API_ENDPOINT = "https://${config.services.netbird-server.domain}";
          NETBIRD_TOKEN_SOURCE = "idToken";
        };
      };
    };
  };
  config = let
    deriv = pkgs.runCommand "template-netbird-dashboard" {} ''
      cp -r ${cfg.package} ./temp


      ${
        lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''export "${name}"="${toStringEnv value}"'') cfg.settings)
      }

      # replace ENVs in the config
      ENV_STR="\$\$USE_AUTH0 \$\$AUTH_AUDIENCE \$\$AUTH_AUTHORITY \$\$AUTH_CLIENT_ID \$\$AUTH_CLIENT_SECRET \$\$AUTH_SUPPORTED_SCOPES \$\$NETBIRD_MGMT_API_ENDPOINT \$\$NETBIRD_MGMT_GRPC_API_ENDPOINT \$\$NETBIRD_HOTJAR_TRACK_ID \$\$NETBIRD_GOOGLE_ANALYTICS_ID \$\$AUTH_REDIRECT_URI \$\$AUTH_SILENT_REDIRECT_URI \$\$NETBIRD_TOKEN_SOURCE \$\$NETBIRD_DRAG_QUERY_PARAMS"

      find temp -type d -exec chmod 755 {} \;
      OIDC_TRUSTED_DOMAINS="./temp/OidcTrustedDomains.js"
      ${pkgs.gettext}/bin/envsubst "$ENV_STR" < "$OIDC_TRUSTED_DOMAINS".tmpl > "$OIDC_TRUSTED_DOMAINS"
      for f in $(grep -R -l AUTH_SUPPORTED_SCOPES ./); do
          ${pkgs.gettext}/bin/envsubst "$ENV_STR" < "$f" > "$f".copy
          mv -f "$f".copy "$f"
      done
      mkdir -p $out
      cp -r ./temp/. $out/
    '';
  in
    mkIf cfg.enable
    {
      services.nginx = mkIf cfg.enableNginx {
        enable = true;
        virtualHosts = {
          ${cfg.domain} = {
            locations = {
              "/" = {
                root = "${deriv}/";
                tryFiles = "$uri $uri.html $uri/ =404";
              };
            };
            extraConfig = ''
              error_page 404 /404.html;
              location = /404.html {
                 internal;
              }
            '';
          };
        };
      };
    };
}
