# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Garland is a NixOS configuration repository managing four machines (named after poisonous plants):
- **foxglove** -- Framework laptop (desktop, x86_64)
- **wisteria** -- Desktop computer (x86_64)
- **hemlock** -- VPS server (headless, x86_64)
- **ivy** -- Raspberry PI running Home Assistant (aarch64)

## Common Commands

```bash
just rebuild          # Rebuild NixOS (alias: just r)
just update           # Update flake inputs (alias: just u)
just secrets <host>   # Edit encrypted secrets for a host (defaults to current hostname)
just cleanup          # GC generations older than 30 days
just build-sd <host>  # Build SD image for aarch64 (Raspberry PI)
just remote-install <flake> <conn_str>  # Remote install via nixos-anywhere
```

## Version Control

This project uses **jj (Jujutsu)** backed by git. Always use `jj` commands instead of `git`:
- `jj status` instead of `git status`
- `jj log` instead of `git log`
- `jj new` / `jj commit` instead of `git commit`

## Architecture

This repository follows the **dendritic pattern** (https://github.com/mightyiam/dendritic): every Nix file under `modules/` is a flake-parts module, auto-imported by **import-tree**. Files and directories prefixed with an underscore are NOT auto-imported (plain NixOS modules referenced by path, e.g. `_hardware-configuration.nix`, `_disk/`).

### Flake Structure

`flake.nix` is minimal: inputs plus `mkFlake` over `import-tree ./modules`. Everything else lives in `modules/`:

- `modules/meta.nix` -- imports `flake-parts.flakeModules.modules`, which provides the `flake.modules.<class>.<name>` namespaces everything writes into
- `modules/nixos-configurations.nix` -- turns every `flake.modules.nixos."hosts/<name>"` into `nixosConfigurations.<name>`
- `modules/templates.nix` -- project templates (rust, zig, elixir, python, gleam, etc.)

### Feature Modules

A feature file defines one feature across all applicable classes: for example `modules/workstation/stylix.nix` sets both `flake.modules.nixos.workstation` (system stylix) and `flake.modules.homeManager.workstation` (home stylix) in one file. Multiple files can merge into the same module name.

Main module names: `base` (all hosts), `workstation` (desktop bundle), `server` (headless bundle), `dev`, `hacking`, and one name per optional feature (`tailscale`, `music`, `llm`, `cad`, `osint`, `"3d-printing"`, `home-assistant`, ...). Server services are `"services/<name>"`, GPU variants `"gpu/amd"`/`"gpu/intel"`, disk layouts `"disk/luks-lvm"`/`"disk/server"`. Home-manager names: `workstation`, `hyprland`, `shell`, `dev`, `monitor-workspaces`.

### Hosts

`modules/hosts/<name>` defines `flake.modules.nixos."hosts/<name>"`: it imports the feature modules the host wants (importing a feature IS enabling it; there are no enable flags or `variables.nix`) plus host-specific config (hostname, disk/boot specifics, wallpaper, monitor layout). Home-manager users are attached there via `home-manager.users.<user>.imports`. Ivy (Raspberry PI, aarch64) is a host module like the others, just importing fewer features plus `nixos-hardware`'s raspberry-pi-3 module.

### Secrets Management

Uses **sops-nix** with age encryption derived from SSH host keys. Secrets are stored encrypted in `secrets/<hostname>.yaml` (path derived from `config.networking.hostName` in `modules/base/sops.nix`) and decrypted at NixOS activation time. Key mapping is in `.sops.yaml`.

## Key Patterns

- No `specialArgs` beyond `inputs`; modules read everything else from `config`
- Flake input modules are imported by the feature that configures them (e.g. `modules/base/nixvim.nix` imports `inputs.nixvim.nixosModules.nixvim`; `modules/home-manager.nix` wires up home-manager)
- Defining a `flake.modules.*` entry activates nothing by itself; orphan features (`gaming`, `opensnitch`, `"services/headscale"`, `"services/ntfy"`, `freetube`) exist as names no host currently imports
- `home.stateVersion` lives in each host file and must never change after install

