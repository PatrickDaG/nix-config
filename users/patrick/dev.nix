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
  hm.programs.zsh.initContent = lib.mkBefore ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    umask 077
  '';
  # For embedded development
  users.groups.plugdev = { };
  services.udev.packages = [
    (pkgs.runCommandLocal "probe-rs-udev-rules" { } ''
      mkdir -p $out/lib/udev/rules.d
      cp ${./69-probe-rs.rules} $out/lib/udev/rules.d/69-probe-rs.rules
    '')
  ];
  nix = {
    distributedBuilds = true;
    buildMachines =
      let
        allMachines = [
          {
            name = "mailnix";
            hostName = globals.hosts.mailnix.ip;
            protocol = "ssh-ng";
            sshUser = "build";
            system = "aarch64-linux";
            sshKey = "/run/builder-unlock/mailnix";
            supportedFeatures = [ ];
            publicHostKey = builtins.readFile "${pkgs.runCommand "MailnixHostKey" { }
              "${pkgs.coreutils}/bin/base64 -w0 ${nodes.mailnix.config.node.secretsDir}/host.pub > $out"
            }";
          }
          {
            name = "thinknix";
            hostName = "thinknix.local";
            protocol = "ssh-ng";
            sshUser = "build";
            system = "x86_64-linux";
            sshKey = "/run/builder-unlock/thinknix";
            supportedFeatures = [
              "kvm"
              "benchmark"
              "nixos-test"
              "big-parallel"
            ];
            publicHostKey = builtins.readFile "${pkgs.runCommand "ThinknixHostKey" { }
              "${pkgs.coreutils}/bin/base64 -w0 ${nodes.thinknix.config.node.secretsDir}/host.pub > $out"
            }";
          }
          {
            name = "desktopnix";
            hostName = "desktopnix.local";
            protocol = "ssh-ng";
            sshUser = "build";
            system = "x86_64-linux";
            sshKey = "/run/builder-unlock/desktopnix";
            supportedFeatures = [
              "kvm"
              "benchmark"
              "nixos-test"
              "big-parallel"
            ];
            publicHostKey = builtins.readFile "${pkgs.runCommand "DesktopnixHostKey" { }
              "${pkgs.coreutils}/bin/base64 -w0 ${nodes.desktopnix.config.node.secretsDir}/host.pub > $out"
            }";
          }
        ];
      in
      builtins.map (m: builtins.removeAttrs m [ "name" ]) (
        builtins.filter (m: m.name != config.node.name) allMachines
      );
  };
}
