{
  config,
  pkgs,
  nixos-hardware,
  ...
}: let
  shell = pkgs.zsh;
in {
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
  ];
  # Set your time zone.
  time.timeZone = "Asia/Seoul";
  rekey.secrets.patrick.file = ../../secrets/patrick.passwd.age;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.patrick = {
    inherit shell;
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    extraGroups = ["wheel" "audio" "video" "input"];
    group = "patrick";
    passwordFile = config.rekey.secrets.patrick.path;
  };
  users.groups.patrick.gid = 1000;
  # Allow users in group video to edit backlight setting

  rekey.secrets.root.file = ../../secrets/root.passwd.age;
  users.users.root = {
    inherit shell;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ"
    ];
    passwordFile = config.rekey.secrets.root.path;
  };

  environment.systemPackages = with pkgs; [
    # xournalpp needs this or else it will crash
    gnome3.adwaita-icon-theme
  ];
  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    umask 077
  '';
}
