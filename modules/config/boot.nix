{
  config,
  lib,
  ...
}: {
  boot = {
    initrd.systemd = {
      enable = true;
      emergencyAccess = config.secrets.secrets.global.users.root.passwordHash;
    };

    initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" "ahci" "uas"];
    supportedFilesystems = ["ntfs"];
    kernelModules = ["kvm-intel"];
    kernelParams = [
      "rd.luks.options=timeout=0"
      "rootflags=x-systemd.device-timeout=0"
    ];

    tmp.useTmpfs = true;
    loader.timeout = lib.mkDefault 2;
  };
}
