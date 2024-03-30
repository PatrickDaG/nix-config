{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit
    (lib)
    types
    mkEnableOption
    mkPackageOption
    mkOption
    ;

  cfg = config.services.actual;
  configFile = formatType.generate "config.json" cfg.settings;

  formatType = pkgs.formats.json {};
in {
  options.services.actual = {
    enable = mkEnableOption "actual, a privacy focused app for managing your finances";
    package = mkPackageOption pkgs "actual" {};
    settings = mkOption {
      default = {};
      type = types.submodule {
        freeformType = formatType.type;
        config = {
          serverFiles = "/var/lib/actual/server-files";
          userFiles = "/var/lib/actual/user-files";
          dataDir = "/var/lib/actual";
        };
      };
    };
  };
  config.systemd.services.actual = {
    after = ["network.target"];
    environment.ACTUAL_CONFIG_PATH = configFile;
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/ln -sf ${cfg.package}/migrations /var/lib/actual/";
      ExecStart = lib.getExe cfg.package;
      User = "actual";
      Group = "actual";
      DynamicUser = true;
      StateDirectory = "actual";
      WorkingDirectory = "/var/lib/actual";
      LimitNOFILE = "1048576";
      PrivateTmp = true;
      PrivateDevices = true;
      StateDirectoryMode = "0700";
      Restart = "always";

      # Hardening
      CapabilityBoundingSet = "";
      LockPersonality = true;
      #MemoryDenyWriteExecute = true; # Leads to coredump because V8 does JIT
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "@pkey"
      ];
      UMask = "0077";
    };
    wantedBy = ["multi-user.target"];
  };
}
