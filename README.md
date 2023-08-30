# Meine wundervolle nix config

## Structure

- `hosts/` contain nixos configuration for hosts
    - `common/` shared configuration modules
        - `core/` base configuration shared on all machines
        - `dev/` configuration enabling dev environment
        - `graphical/` configuration for graphical environments
        - `hardware/` configuration for hardware components
    - `<hostname>/` configuration for hosts
        - `default.nix` Toplevel system definition
        - `fs.nix` file system definiton
        - `net.nix` network setup
        - `secrets/` secrets local to this hosts
            - `secrets.nix.age` local secrets usable on deploy
            - `host.pub` host public key, needed for rekeying agenix secrets
- `modules/` extra nixos modules
    - `secrets.nix` module to enable deploy-time secrets
- `nix/` additional nix functions
    - `checks.nix` pre-commit checks
    - `colmena.nix` Setup for using colmena to deploy
    - `devshell.nix` Development shell
    - `extra-builtins.nix` Extra builtin plugin file to enable repository secrets
    - `generate-node.nix` logic to generate nodes for colmena
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
        - `impermanence.nix` hm-impermanence setup for users
        - `default.nix` minimal setup for all users
        - `interactive.nix` minimal setup for interactive users on a command line
        - `graphical.nix` configuration for users utilizing a graphical interface
    - `<username>/` configuration for users
        - `impermanence.nix` users persistence configuration

## Hosts
- `patricknix` my main laptop
- `desktopnix` my main desktop

## Users
- `patrick` my normal everyday unprivileged user
- `root` root user imported by every host

## Flake output structure
- `apps` executables used for editing this configuration
    - `edit-secret` edit an age encrypted secret
    - `rekey` rekey all secret files for the host's secret key, enabling agenix
    - `rekey-save-output` only internal use
- `checks` linting and other checks for this repository
    - `pre-commit-check` automatic checks executed as pre-commit hooks
- `colmena` outputs used by colmena
- `colmenaNodes` per node configuration
- `nodes` alias to `colmenaNodes`
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
3. Copy ISO to usb and boot


## Deploy

```bash
colmena apply --on <hostname>
```
If deploying from a host not containing the necessary nix configuration option append
```bash
--nix-option plugin-files "$NIX_PLUGINS"/lib/nix/plugins --nix-option extra-builtins-file ./nix/extra-builtins`
```
