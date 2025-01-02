{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  cfg = {
    interfaces = "lan-.*";
    rules = [
      {
        from = ".*";
        to = "lan-home";
        allow_questions = "";
        allow_answers = ".*";
      }
      {
        from = "lan-home";
        to = "lan-services";
        allow_questions = "(nucnix|elisabeth)";
        allow_answers = "";
      }
      {
        from = "lan-home";
        to = "lan-devices";
        allow_questions = "(printer|ipp)";
        allow_answers = "";
      }
    ];
  };
in
{
  systemd.services.mdns-relay = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    #environment.RUST_LOG = "debug";

    serviceConfig = {
      Restart = "on-failure";
      ExecStart = "${
        lib.getExe inputs.mdns.packages.${pkgs.system}.default
      } -c ${pkgs.writeText "config.json" (builtins.toJSON cfg)}";

      # Hardening
      DynamicUser = true;
      CapabilityBoundingSet = "";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateUsers = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateMounts = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      UMask = "0027";
    };
  };
}
