{
  inputs,
  lib,
  minimal,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../config/basic
    ../../config/optional/initrd-ssh.nix

    ../../config/hardware/physical.nix
    ../../config/optional/zfs.nix

    ./net.nix
    ./fs.nix
  ] ++ lib.lists.optionals (!minimal) [ ../../config/services/octoprint.nix ];
  services.xserver.xkb = {
    layout = "de";
  };
  services.thermald.enable = lib.mkForce false;
  nixpkgs.hostPlatform = "x86_64-linux";
}
