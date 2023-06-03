{nixos-hardware, ...}: {
  imports = [
    nixos-hardware.common-cpu-intel
    nixos-hardware.common-gpu-intel
    nixos-hardware.common-pc-laptop
    nixos-hardware.common-pc-laptop-ssd

    ../common/core
    ../common/dev

    ../common/graphical/fonts.nix
    ../common/graphical/steam.nix

    ../common/hardware/bluetooth.nix
    ../common/hardware/intel.nix
    ../common/hardware/laptop.nix
    ../common/hardware/physical.nix
    ../common/hardware/pipewire.nix
    ../common/hardware/yubikey.nix
    ../common/hardware/zfs.nix

    ../common/hardware/nvidia.nix
    ../common/hardware/prime-offload.nix

    ./net.nix
    ./fs.nix
    ./smb-mounts.nix
    ./wireguard.nix

    ../../users/patrick
  ];
  # Set your time zone.
  time.timeZone = "Asia/Seoul";
  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    umask 077
  '';
}
