This file contains a small overview over the contents and structure of this repository, mainly for me to remember where I put my shit.

- `config/` contains shared nixos configuration
    - `basic/` the basic system configuration, this should be applied for all systems
        - `system.nix` a far descendant of the original `configuration.nix`
            any global configuration should be done here first and later moved to their own file if necessary
    - `support/` configuration for supporting specific hardware or use cases on a system level
    - `services/` configuration for independent services
- `hosts/` contain nixos configuration for hosts
    - `<hostname>/` configuration for hosts
        - `default.nix` Toplevel system definition
        - `fs.nix` file system definiton
        - `net.nix` network setup
        - *`guests.nix`* optional config for guest systems
        - `secrets/` secrets local to this hosts
            - `secrets.nix.age` local secrets usable while evaluating
            - `host.pub` host public key, needed for rekeying agenix secrets
- `keys/` public keys needed for evaluating the system
- `modules/` extra nixos modules
- `modules-hm/` extra home-manager or home management modules
- `nix/` additional nix functions
    - `devshell.nix` Development shell
    - `extra-builtins.nix` Extra builtin plugin file to enable repository secrets
- `pkgs/` additional packages
- `secrets/` global secrets
    - `recipients.txt` rage recipient file for encrypting secrets
        - currently containing all yubikeys and a rage backup key
    - `secrets.nix.age` global secrets available at deploy
- `users/` home manager user configuration
    - `patrick` personal configuration for myself
        - `programs/` configuration for miscellaneous programs
        - `wayland/` configuration for wayland windowmanagers and basic utilities
        - `xorg/` configuration for xorg windowmanagers and basic utilities
    - `root` minimal configuration for root
' `patches` patche to be applied to nixpkgs before the system is built
