# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake-based configuration managing multiple hosts (desktops, laptops, servers) with home-manager for user configuration, agenix for secrets, and microvm for guest VMs.

## Common Commands

Enter the development shell (required for most operations):
```bash
nix develop
```

Format all files:
```bash
nix fmt
```

Build a host configuration:
```bash
nim build <hostname>
```

Deploy to a host:
```bash
nim deploy <hostname>
```

Manage secrets:
```bash
agenix generate   # Generate new secrets
agenix rekey      # Rekey all secrets after adding hosts/keys
```

Build a live ISO for installation:
```bash
nix build --print-out-paths --no-link .#images.<target-system>.live-iso
```

When deploying from a host without nix-plugins configured:
```bash
--nix-option plugin-files "$NIX_PLUGINS"/lib/nix/plugins --nix-option extra-builtins-file ./nix/extra-builtins.nix
```

## Architecture

### Directory Structure

- `hosts/<hostname>/` - Per-host NixOS configuration
  - `default.nix` - Main host config, imports support modules and user configs
  - `fs.nix` - Filesystem/disk layout (disko)
  - `net.nix` - Network configuration
  - `guests.nix` - MicroVM guest definitions (servers only)
  - `secrets/` - Host-specific secrets and `host.pub` for agenix

- `config/basic/` - Shared base configuration applied to all hosts
- `config/support/` - Optional feature modules (bluetooth, nvidia, zfs, secureboot, etc.)
- `config/services/` - Service configurations (forgejo, immich, nextcloud, etc.)

- `users/<username>/` - Home-manager configurations
- `modules/` - Custom NixOS modules
- `modules-hm/` - Custom home-manager modules
- `globals.nix` - Global service definitions and network configuration (VLANs, domains)
- `ids.json` - Deterministic UID/GID assignments for services

### Key Patterns

**Secrets**: Uses agenix-rekey with yubikey-based master identities. Secrets are encrypted in `secrets/` directories and decrypted at runtime via `rageImportEncrypted`.

**Impermanence**: Root filesystem is ephemeral. Persistent state is explicitly declared and stored on separate ZFS datasets.

**Services**: Each service in `config/services/` typically runs in a microvm guest defined in the host's `guests.nix`. Services need entries in `globals.nix` for domain/IP and in `ids.json` for UID allocation.

**Formatting**: Pre-commit hooks run nixfmt, deadnix, statix, keep-sorted, and shellcheck via treefmt.

### Adding New Services

1. Create service config in `config/services/<service>.nix`
2. Add UID to `ids.json` and `config/basic/users.nix`
3. Add domain/service definitions to `globals.nix`
4. Add VM/container to host's `guests.nix`
5. Run `agenix generate && agenix rekey`
6. Deploy, fetch SSH hostkey with `ssh-keyscan`, rekey again, deploy again
