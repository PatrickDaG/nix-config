{
  config,
  lib,
  pkgs,
  globals,
  ...
}:
{
  boot = lib.mkIf (!config.boot.isContainer) {
    initrd.systemd = {
      enable = true;
      emergencyAccess = globals.users.root.hashedPassword;
      extraBin.ip = "${pkgs.iproute2}/bin/ip";
      extraBin.cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
      users.root.shell = "${pkgs.bashInteractive}/bin/bash";
      storePaths = [ "${pkgs.bashInteractive}/bin/bash" ];
    };

    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "r8169"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "rtsx_pci_sdmmc"
      "ahci"
      "uas"
      "tpm_crb"
    ];
    supportedFilesystems = [ "ntfs" ];
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "rd.luks.options=timeout=0"
      "rootflags=x-systemd.device-timeout=0"
      # NOTE: Add "rd.systemd.unit=rescue.target" to debug initrd
      #"rd.systemd.unit=rescue.target"
    ];

    tmp.useTmpfs = true;
    loader.timeout = lib.mkDefault 2;
    initrd.systemd.services."zfs-import-rpool".after = [ "cryptsetup.target" ];
  };
}
