{
  inputs,
  minimal,
  lib,
  ...
}: {
  imports =
    [
      inputs.nixos-hardware.nixosModules.common-pc
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.nixos-hardware.nixosModules.common-pc-hdd
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate

      ../../modules/config
      ../../modules/optional/initrd-ssh.nix
      ../../modules/optional/secureboot.nix

      ../../modules/hardware/physical.nix
      ../../modules/hardware/zfs.nix

      ./net.nix
      ./fs.nix
    ]
    ++ lib.lists.optionals (!minimal) [
      ./guests.nix
    ];
  services.xserver = {
    layout = "de";
    xkbVariant = "bone";
  };
}
