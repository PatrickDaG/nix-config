{
  pkgs,
  lib,
  config,
  ...
}: {
  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
  ];
  age.secrets.secureboot.rekeyFile = ../../hosts/${config.node.name}/secrets/secureboot.tar.age;
  system.activationScripts.securebootuntar = {
    text = ''
      rm -r /run/secureboot || true
      mkdir -p /run/secureboot
      ${pkgs.gnutar}/bin/tar xf ${config.age.secrets.secureboot.path} -C /run/secureboot || true
    '';
    deps = ["agenix"];
  };

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    enrollKeys = true;
    pkiBundle = "/run/secureboot";
  };
}
