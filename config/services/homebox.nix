{
  lib,
  pkgs,
  config,
  ...
}: {
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [config.services.forgejo.settings.server.HTTP_PORT];
  };
  systemd.services.homebox = {
    after = ["network.target"];
    environment = {
      HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
    };
    script = ''
      ${lib.getExe pkgs.homebox} \
      --mode production \
      --web-port 3000 \
      --storage-data ./data \
      --storage-sqlite-url "./data/homebox.db?_pragma=busy_timeout=999&_pragma=journal_mode=WAL&_fk=1" \
      --options-allow-registration false
    '';
    serviceConfig = {
      User = "homebox";
      Group = "homebox";
      DynamicUser = true;
      StateDirectory = "homebox";
      WorkingDirectory = "/var/lib/homebox";
      LimitNOFILE = "1048576";
      PrivateTmp = true;
      PrivateDevices = true;
      StateDirectoryMode = "0700";
      Restart = "always";

      # Hardening
      CapabilityBoundingSet = "";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
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
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/homebox/";
      user = "homebox";
      group = "homebox";
      mode = "750";
    }
  ];
}
