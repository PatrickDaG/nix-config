{
  inputs,
  lib,
  minimal,
  ...
}: {
  imports =
    [
      inputs.nixos-hardware.nixosModules.common-pc
      inputs.nixos-hardware.nixosModules.common-pc-ssd

      ../../modules/config
      ../../modules/optional/initrd-ssh.nix

      ../../modules/hardware/intel.nix
      ../../modules/hardware/physical.nix
      ../../modules/hardware/zfs.nix

      ./net.nix
      ./fs.nix
    ]
    ++ lib.lists.optionals (!minimal) [
      ../../modules/services/samba.nix
      ../../modules/services/nextcloud.nix
    ];
  services.xserver = {
    layout = "de";
    xkbVariant = "bone";
  };
  services.thermald.enable = lib.mkForce false;
}
