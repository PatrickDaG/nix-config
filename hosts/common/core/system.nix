{
  inputs,
  lib,
  nodePath,
  pkgs,
  nodeName,
  ...
}: {
  age.rekey = {
    inherit
      (inputs.self.secretsConfig)
      masterIdentities
      extraEncryptionPubkeys
      ;

    forceRekeyOnSystem = builtins.extraBuiltins.unsafeCurrentSystem;
    hostPubkey = let
      pubkeyPath = nodePath + "/secrets/host.pub";
    in
      lib.mkIf (lib.pathExists pubkeyPath || lib.trace "Missing pubkey for ${nodeName}: ${toString pubkeyPath} not found, using dummy replacement key for now." false)
      pubkeyPath;
  };
  boot = {
    initrd.systemd.enable = true;
    initrd.systemd.emergencyAccess = true;
    initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc"];
    supportedFilesystems = ["ntfs"];
    kernelModules = ["kvm-intel"];
    tmp.useTmpfs = true;
  };

  security.sudo.enable = false;

  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n.defaultLocale = "C.UTF-8";
  services.xserver = {
    layout = "de";
    xkbVariant = "bone";
  };
  console = {
    font = "ter-v28n";
    packages = with pkgs; [terminus_font];
    useXkbConfig = true; # use xkbOptions in tty.
    keyMap = lib.mkDefault "de-latin1-nodeadkeys";
  };

  users.mutableUsers = false;
  environment.systemPackages = with pkgs; [
    wget
    gcc
    tree
    rage
    file
    ripgrep
    killall
    fd
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  secrets.secretFiles = let
    local = nodePath + "/secrets/secrets.nix.age";
  in
    {
      global = ../../../secrets/secrets.nix.age;
    }
    // lib.optionalAttrs (nodePath != null && lib.pathExists local) {inherit local;};
}
