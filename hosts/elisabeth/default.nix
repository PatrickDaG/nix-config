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

      ../../config/basic

      ../../config/optional/initrd-ssh.nix
      ../../config/optional/secureboot.nix
      ../../config/optional/zfs.nix

      ../../config/hardware/physical.nix

      ./blog.nix
      ./net.nix
      ./fs.nix
    ]
    ++ lib.lists.optionals (!minimal) [
      ./guests.nix
    ];
  services.xserver = {
    xkb = {
      layout = "de";
      variant = "bone";
    };
  };
}
