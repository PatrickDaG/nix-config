{
  config,
  nodes,
  lib,
  pkgs,
  ...
}: let
  prestart = pkgs.writeShellScript "pr-tracker-pre" ''
    if [ ! -d "$DIRECTORY" ]; then
      ${lib.getExe pkgs.git} clone https://github.com/NixOS/nixpkgs.git
    fi
  '';
in {
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/pr-tracker";
      user = "pr-tracker";
      group = "pr-tracker";
      mode = "0700";
    }
  ];
  age.secrets.maddyPasswd = {
    generator.script = "alnum";
    owner = "pr-tracker";
  };
  age.secrets.prTrackerEnv = {
    rekeyFile = config.node.secretsDir + "/pr-tracker-env.age";
    owner = "pr-tracker";
  };
  age.secrets.prTrackerWhiteList = {
    rekeyFile = config.node.secretsDir + "/pr-tracker-white-list.age";
    owner = "pr-tracker";
  };
  nodes.maddy = {
    age.secrets.pr-trackerPasswd = {
      inherit (config.age.secrets.maddyPasswd) rekeyFile;
      inherit (nodes.maddy.config.services.maddy) group;
      mode = "640";
    };
    services.maddy.ensureCredentials = {
      "pr-tracker@${config.secrets.secrets.global.domains.mail_public}".passwordFile = nodes.maddy.config.age.secrets.vaultwardenPasswd.path;
    };
  };
  systemd.sockets.pr-tracker = {
    listenStreams = "0.0.0.0:300";
  };
  systemd.services.pr-tracker = {
    after = ["network.target"];
    script = ''
      ${lib.getExe pkgs.pr-tracker} --url pr-tracker.${config.secrets.secrets.gloab.domain}\
        --user-agent "Patricks pr-tracker"\
        --path nixpks --remote origin\
        --white-list ${config.age.secrets.prTrackerEnv.path};
    '';
    serviceConfig = {
      User = "pr-tracker";
      Group = "pr-tracker";
      StateDirectory = "pr-tracker";
      WorkingDirectory = "/var/lib/pr-tracker";
      LimitNOFILE = "1048576";
      PrivateTmp = true;
      PrivateDevices = true;
      StateDirectoryMode = "0700";
      Restart = "always";
      ExecStartPre = prestart;
      EnvironmentFile = config.age.secrets.prTrackerEnv.path;

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
  systemd.timers.pr-tracker-update = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "30m";
      OnUnitActiveSec = "30m";
    };
  };

  systemd.services.pr-tracker-update = {
    script = ''
      set -eu
      ${lib.getExe pkgs.git} -C nixpkgs fetch
      ${lib.getExe pkgs.curl} http://localhost:3000/update
    '';
    serviceConfig = {
      Requires = "pr-tracker";
      Type = "oneshot";
      User = "pr-tracker";
      Group = "pr-tracker";
      StateDirectory = "pr-tracker";
      WorkingDirectory = "/var/lib/pr-tracker";
      LimitNOFILE = "1048576";
      PrivateTmp = true;
      PrivateDevices = true;
      StateDirectoryMode = "0700";
      Restart = "always";
      ExecStartPre = prestart;
      EnvironmentFile = config.age.secrets.prTrackerEnv.path;
    };
  };
}
