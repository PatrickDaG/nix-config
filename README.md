# Meine wundervolle nix config

## Structure

- `hosts/` contain nixos configuration for hosts
    - `<hostname>/` configuration for hosts
        - `default.nix` Toplevel system definition
        - `fs.nix` file system definiton
        - `net.nix` network setup
        - `secrets/` secrets local to this hosts
            - `secrets.nix.age` local secrets usable on deploy
            - `host.pub` host public key, needed for rekeying agenix secrets
- `modules/` extra nixos modules and shared configurations
    - `secrets.nix` module to enable deploy-time secrets
    - `config/` base configuration used on all machines
    - `dev/` configuration options enabling developer environment
    - `graphical/` configuration for graphical environments
    - `hardware/` configuration for hardware components
    - `impermanence/` impermanence modules for hosts
- `nix/` additional nix functions
    - `devshell.nix` Development shell
    - `extra-builtins.nix` Extra builtin plugin file to enable repository secrets
    - TODO
    - `lib.nix` additional library functions
- `secrets/` global secrets
    - `<name>.key.pub` public key handles to decrypt secrets using yubikey
    - `recipients.txt` rage recipient file for encrypting secrets
        - currently containing both yubikeys and a rage backup key
    - `secrets.nix.age` global secrets available at deploy
- `users/` home manager user configuration
    - `common/` shared home-manager modules
        - `graphical/` configuration for graphical programs
        - `programs/` configuration for miscellaneous programs
        - `shells/` configuration for shells
        - `default.nix` minimal setup for all users
        - `interactive.nix` minimal setup for interactive users on a command line
        - `graphical.nix` configuration for users utilizing a graphical interface
    - `<username>/` configuration for users
        - `impermanence.nix` users persistence configuration

## Hosts
- `patricknix` my main laptop
- `desktopnix` my main desktop
- `testienix` old laptop for testing

## Users
- `patrick` my normal everyday unprivileged user
- `root` root user imported by every host

## Flake output structure
- `checks` linting and other checks for this repository
    - `pre-commit-check` automatic checks executed as pre-commit hooks
- `nixosHosts` top level configs for hosts
- `nodes` alias to `nixosNodes`
- `devshell` development shell using devshell
- `formatter` nix code formatter
- `hosts` host meta declaration
- `pkgs` nixpkgs
- `packages` additional packages
- `secretsConfig` meta configuration for secrets
- `stateVersion` global stateversion used by nixos and home-manager to determine default config

## How-To

### Add additional hosts

1. Add host definition to `hosts.toml`
2. Create host configuration in `hosts/<name>`
    1. Create and fill `default.nix`
    1. Fill `net.nix`
    1. Fill `fs.nix`
    2. Don't forget to add necesarry config for filesystems, etc.
3. Generate ISO image with `nix build --print-out-paths --no-link .#images.<target-system>.live-iso`
    - This might take multiple minutes(~10)
    - Alternatively boot an official nixos image connect with password
3. Copy ISO to usb using dd
3. After booting copy the installer to the live system using `nix copy --to <target> .#packages.<target-system>.installer-package.<target>`
4. Run the installer script from the nix store of the live system
    - you can get the path using `nix path-info .#packages.<target-system>.installer-package.<target>`
4. Export all zpools and reboot into system
6. Retrieve hostkeys using `ssh-keyscan <host> | grep -o 'ssh-ed25519.*' > host/<target>/secrets/host.pub`
5. Deploy system

### Add secureboot to new systems
1. generate keys with `sbct create-keys'
1. tar the resulting folder using `tar cvf secureboot.tar -C /etc/secureboot`
1. Copy the tar to local using scp and encrypt it using rage
1. safe the encrypted archive to `hosts/<host>/secrets/secureboot.tar.age`
1. *DO NOT* forget to delete the unecrypted archives
1. link `/run/secureboot` to `/etc/secureboot`
1. This is necesarry since for your next apply the rekeyed keys are not yet available but needed for signing the boot files
1. ensure the boot files are signed using `sbctl verify`
1. Now reboot the computer into BIOS and enable secureboot
    this may include removing any existing old keys
1. bootctl should now read `Secure Boot: disabled (setup)`
1. you can now enroll your secureboot keys using
1. `sbctl enroll-keys`
    If you want to be able to boot microsoft signed images append `--microsoft`
1. Time to reboot and pray

TPM keys
`systemd-cryptenroll --tpm2-pcrs=7+8+9 --tpm2-with-pin={yes/no} --tpm2-device=auto <device>`


## Deploy

If deploying from a host not containing the necessary nix configuration option append
```bash
--nix-option plugin-files "$NIX_PLUGINS"/lib/nix/plugins --nix-option extra-builtins-file ./nix/extra-builtins`
```
