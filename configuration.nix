{
  config,
  pkgs,
  ...
}: let
  shell = pkgs.zsh;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #user home configuration
    ./users
    #
    ./modules/pipewire.nix
    ./modules/rekey.nix
    ./modules/nvidia.nix
    ./modules/wireguard.nix
    ./modules/smb-mounts.nix
    ./modules/networking.nix
    ./modules/nix.nix
    #./modules/xserver.nix
    ./modules/hyprland.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "patricknix"; # Define your hostname.
  networking.hostId = "68438432";

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
  i18n.defaultLocale = "C.UTF-8";
  services.xserver = {
    layout = "de";
    xkbVariant = "bone";
  };
  console = {
    font = "ter-v28n";
    packages = with pkgs; [terminus_font];
    useXkbConfig = true; # use xkbOptions in tty.
  };
  # Identities with which all secrets are encrypted
  rekey.masterIdentityPaths = [./secrets/NIXOSc.key ./secrets/NIXOSa.key];

  rekey.pubKey = ./keys + "/${config.networking.hostName}.pub";

  hardware.opengl.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.tlp.enable = true;

  # Disable mutable Users, any option can only be set by the nix config
  users.mutableUsers = false;

  rekey.secrets.patrick.file = ./secrets/patrick.passwd.age;

  environment.etc.issue.text = ''
    <<< Welcome to NixOS 23.05.20230304.3c5319a (\m) - \l >>>
  '';

  users.motd = "Guten Tach";
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
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
  '';

  rekey.secrets.root.file = ./secrets/root.passwd.age;
  users.users.root = {
    inherit shell;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ"
    ];
    passwordFile = config.rekey.secrets.root.path;
  };

  security.sudo.enable = false;

  documentation.dev.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xterm
    wget
    gcc
    tree
    age-plugin-yubikey
    rage
    file
    ripgrep
    killall
    fd
    man-pages
    man-pages-posix
    # xournalpp needs this or else it will crash
    gnome3.adwaita-icon-theme
  ];
  # HM zsh needs this or else the startup order is fucked
  # and env variables will be loaded incorrectly
  programs.zsh.enable = true;

  services.physlock.enable = true;

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          # vampir überlebende braucht diese pkgs
          libgdiplus
          cups
        ];
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
    };
    hostKeys = [
      {
        # never set this to an actual nix type path
        # or else .....
        # it will end up in the nix store
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  services.thermald.enable = true;
  services.pcscd.enable = true;
  services.fstrim.enable = true;
  hardware.cpu.intel.updateMicrocode = true;

  services.udev.packages = with pkgs; [yubikey-personalization libu2f-host];

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    umask 077
  '';
  # XDG base spec
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_STATE_HOME = "\${HOME}/.local/state";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    # xdg ninja recommendations
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nv";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    WINEPREFIX = "${XDG_DATA_HOME}/wine";
  };
}
