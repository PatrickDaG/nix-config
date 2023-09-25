{
  pkgs,
  lib,
  config,
  ...
}: {
  # HOW TO: Add secureboot to new systems
  # generate keys with `sbct create-keys'
  # tar the resulting folder using
  # `tar cvf secureboot.tar -C /etc/secureboot .
  # Copy the tar to local using scp
  # and encrypt it using rage
  # safe the encrypted archive to hosts/<host>/secrets/secureboot.tar.age
  # DO NOT forget to delete the unecrypted archives
  # link /run/secureboot to /etc/secureboot
  # This is necesarry since for the first
  # apply the rekeyed keys are not yet available but needed for
  # signing the boot files
  # ensure the boot files are signed using
  # `sbctl verify'
  # Now reboot the computer into BIOS and
  # enable secureboot, this may include
  # removing old keys
  # bootctl should now read
  # `Secure Boot: disabled (setup)'
  # you can now enroll your secureboot keys using
  # `sbctl enroll-keys`
  # If you want to be able to boot microsoft signed images append
  # `--microsoft`
  # Time to reboot and pray
  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    (pkgs.sbctl.override
      {
        databasePath = "/run/secureboot";
      })
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
    # Not usable anyway
    #enrollKeys = true;
    pkiBundle = "/run/secureboot";
  };
}
