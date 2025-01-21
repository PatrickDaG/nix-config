{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkPackageOption
    mkEnableOption
    getExe'
    mkIf
    mkMerge
    optional
    ;
in
{
  options.services.firezone = {
    gui-client = {
      package = mkPackageOption pkgs "firezone-gui-client" { };
      enable = mkEnableOption "the gui client and corresponding ipc service for firezone.";
    };
    headless-client = {
      package = mkPackageOption pkgs "firezone-headless-client" { };
      enable = mkEnableOption "the headless firezone client as service.";
      firezoneTokenFile = mkOption {
        type = types.str;
        description = "A file containing your service account token.";
        example = "";
      };
    };
  };
  config =
    let
      cfg = config.services.firezone;
      sharedServiceConfig = {
        description = "Firezone Client";
        after = "systemd-resolved.service";
        wants = "systemd-resolved.service";

        serviceConfig = {

          AmbientCapabilities = "CAP_NET_ADMIN";
          CapabilityBoundingSet = "CAP_CHOWN CAP_NET_ADMIN";
          DeviceAllow = "/dev/net/tun";
          LockPersonality = "true";
          LogsDirectory = "dev.firezone.client";
          LogsDirectoryMode = "755";
          MemoryDenyWriteExecute = "true";
          NoNewPrivileges = "true";
          PrivateMounts = "true";
          PrivateTmp = "true";
          PrivateUsers = "false";
          ProcSubset = "pid";
          ProtectClock = "true";
          ProtectControlGroups = "true";
          ProtectHome = "true";
          ProtectHostname = "true";
          ProtectKernelLogs = "true";
          ProtectKernelModules = "true";
          ProtectKernelTunables = "true";
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK AF_UNIX";
          RestrictNamespaces = "true";
          RestrictRealtime = "true";
          RestrictSUIDSGID = "true";
          RuntimeDirectory = "dev.firezone.client";
          StateDirectory = "dev.firezone.client";
          SystemCallArchitectures = "native";
          SystemCallFilter = "@aio @basic-io @file-system @io-event @ipc @network-io @signal @system-service";
          UMask = "077";

          Environment.LOG_DIR = "/var/log/dev.firezone.client";

          Type = "notify";
          # Unfortunately we need root to control DNS
          User = "root";
          Group = "firezone-client";
        };

        wantedBy = [ "multi-user.target" ];
      };
    in
    mkMerge [
      (optional cfg.gui-client.enable {
        systemd.services.firezone-client-ipc = mkIf sharedServiceConfig // {
          ExecStart = "${getExe' "firezone-client-ipc" cfg.gui-client.package} run";
        };
        # firezone has this group hard coded
        users.groups.firezone-client = { };
        environment.systemPackages = [ cfg.gui-client.package ];
      })
      (optional cfg.headless-client.enable {
        systemd.services.firezone-client-headless = mkIf sharedServiceConfig // {
          ExecStart = ''
            ${getExe' "firezone-client-ipc" cfg.headless-client.package} standalone \
            --token-path ${cfg.headless-client.firezoneTokenFile}
          '';
        };
        # firezone has this group hard coded
        users.groups.firezone-client = { };
        environment.systemPackages = [ cfg.gui-client.package ];
      })
    ];

  meta.maintainers = with lib.maintainers; [
    oddlama
    patrickdag
  ];
}
