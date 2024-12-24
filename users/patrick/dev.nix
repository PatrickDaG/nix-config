{
  lib,
  config,
  nodes,
  globals,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  age.secrets.nix-key = {
    rekeyFile = ../../secrets/nix-key.age;
    generator.script =
      {
        pkgs,
        file,
        ...
      }:
      ''
        priv=$(${lib.getExe pkgs.nix} key generate-secret --key-name patrickdag.lel.lol-1)
        ${lib.getExe pkgs.nix} key convert-secret-to-public <<< "$priv" > ${
          lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")
        }
        echo "$priv"
      '';
  };
  nix.settings = {
    secret-key-files = [
      config.age.secrets.nix-key.path
    ];
  };
  environment.systemPackages = with pkgs; [
    python3
    jq
    nix-update
    gnumake
    pciutils
    gcc
    usbutils
    man-pages
    man-pages-posix
  ];

  services.nixseparatedebuginfod.enable = true;
  environment = {
    enableDebugInfo = true;
  };
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = false;
    man.enable = true;
    info.enable = false;
    nixos.enable = false;
  };
  hm.programs.zsh.initExtra = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    umask 077
  '';
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = globals.hosts.mailnix.ip;
        protocol = "ssh-ng";
        sshUser = "build";
        system = "aarch64-linux";
        sshKey = "/run/builder-unlock/mailnix";
        supportedFeatures = [
          "big-parallel"
          #"kvm"
        ];
        publicHostKey = builtins.readFile "${pkgs.runCommand "base64HoseKey" { }
          ''${pkgs.coreutils}/bin/base64 -w0 ${nodes.mailnix.config.node.secretsDir}/host.pub > $out''
        }";
      }
    ];
  };
}
