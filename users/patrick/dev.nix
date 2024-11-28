{
  lib,
  config,
  nodes,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
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
        hostName = config.secrets.secrets.global.user.mailnix_ip;
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
