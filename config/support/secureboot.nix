{
  lib,
  minimal,
  pkgs,
  config,
  ...
}:
lib.optionalAttrs (!minimal) {
  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
  ];
  age.secrets.secureboot.rekeyFile = ../../hosts/${config.node.name}/secrets/secureboot.tar.age;
  system.activationScripts.securebootuntar = {
    # TODO sbctl config file
    text = ''
      rm -r /var/lib/sbctl || true
      mkdir -p /var/lib/sbctl
      ${pkgs.gnutar}/bin/tar xf ${config.age.secrets.secureboot.path} -C /var/lib/sbctl || true
      chmod 700 /var/lib/sbctl
    '';
    deps = [ "agenix" ];
  };

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl/";
    # MeasuredBoot limitation
    # FIXME: Figure out why this does not work
    # configurationLimit = 8;
    # measuredBoot = {
    #   enable = true;
    #   pcrs = [
    #     0
    #     4
    #     7
    #     # Not supported
    #     #15
    #   ];
    # };
  };
  environment.persistence."/state".files = [
    config.boot.lanzaboote.measuredBoot.pcrlockPolicy
  ];
  environment.persistence."/state".directories = [
    config.boot.lanzaboote.measuredBoot.pcrlockDirectory
  ];
}
