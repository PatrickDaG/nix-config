{nixos-hardware, ...}: {
  imports = [
    nixos-hardware.common-cpu-intel
    nixos-hardware.common-gpu-intel
    nixos-hardware.common-pc-laptop
    nixos-hardware.common-pc-laptop-ssd

    ../common/core
    ../common/dev
    ../common/graphical
    ../common/hardware/bluetooth.nix
    ../common/hardware/intel.nix
    ../common/hardware/physical.nix
    ../common/efi.nix
    ../common/laptop.nix
    ../common/pipewire.nix
    ../common/steam.nix
    ../common/yubikey.nix
    ../common/zfs.nix

    ../common/hardware/nvidia.nix
    ./prime-offload.nix

    ./net.nix
    ./fs.nix
    ./smb-mounts.nix
    ./wireguard.nix

    ../../users/patrick
    ../../users/root
  ];
  # Set your time zone.
  time.timeZone = "Asia/Seoul";
  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    umask 077
  '';
}
