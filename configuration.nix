# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
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
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "patricknix"; # Define your hostname.
  networking.hostId = "68438432";

  # Identities with which all secrets are encrypted
  rekey.masterIdentityPaths = [./secrets/NIXOSc.key ./secrets/NIXOSa.key];

  rekey.pubKey = ./keys + "/${config.networking.hostName}.pub";

  networking.wireless.iwd.enable = true;
  rekey.secrets.eduroam = {
    file = ./secrets/iwd/eduroam.8021x.age;
    path = "/etc/iwd/eduroam.8021x";
  };
  rekey.secrets.devoloog = {
    file = ./secrets/iwd/devolo-og.psk.age;
    path = "/etc/iwd/devolo-og.psk";
  };

  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  # Should remain enabled since nscd from glibc is kinda ass
  services.nscd.enableNsncd = true;
  systemd.network.wait-online.anyInterface = true;
  services.resolved = {
    enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "C.UTF-8";
  console = {
    font = "ter-v28n";
    packages = with pkgs; [terminus_font];
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    layout = "de";
    xkbVariant = "bone";
    autoRepeatDelay = 235;
    autoRepeatInterval = 60;
    videoDrivers = ["modesetting"];
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad = {
        accelProfile = "flat";
        naturalScrolling = true;
      };
    };
  };
  services.autorandr.enable = true;
  services.physlock.enable = true;

  nixpkgs.config.allowUnfree = true;

  powerManagement.powertop.enable = true;

  # Disable mutable Users, any option can only be set by the nix config
  users.mutableUsers = false;

  rekey.secrets.patrick.file = ./secrets/patrick.passwd.age;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.patrick = {
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    extraGroups = ["wheel" "audio" "video" "input"];
    group = "patrick";
    shell = pkgs.fish;
    passwordFile = config.rekey.secrets.patrick.path;
  };
  users.groups.patrick.gid = 1000;

  rekey.secrets.root.file = ./secrets/root.passwd.age;
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ"
    ];
    shell = pkgs.fish;
    passwordFile = config.rekey.secrets.root.path;
  };

  security.sudo.enable = false;

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
    # xournalpp needs this or else it will crash
    gnome3.adwaita-icon-theme
  ];

  programs.steam.enable = true;

  # List services that you want to enable:

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
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.udev.packages = with pkgs; [yubikey-personalization libu2f-host];

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # breaks flake based building
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix = {
    settings = {
      auto-optimise-store = true;
      allowed-users = ["@wheel"];
      trusted-users = ["root" "@wheel"];
      system-features = ["recursive-nix"];
      substituters = [
        "https://nix-config.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      cores = 0;
      max-jobs = "auto";
    };
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedPriority = 5;
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes recursive-nix
      flake-registry = /etc/nix/registry.json
    '';
    optimise.automatic = true;
    gc.automatic = true;
  };
}
