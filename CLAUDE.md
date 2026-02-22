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

### Flake Structure

`flake.nix` uses **flake-parts** and defines:
- `nixosConfigurations` for all four hosts via a `mkSystem` helper in `nixos/default.nix`
- `templates` for bootstrapping new projects (rust, zig, elixir, python, gleam, etc.)

Each host configuration is assembled from: `nixos/<hostname>/configuration.nix` + `hardware-configuration.nix` + flake module inputs (disko, stylix, nixvim, sops-nix, home-manager).

### Module Organization

`modules/default.nix` is the base module set imported by all desktop hosts. It aggregates:
- Base: `sops.nix`, `env.nix`, `packages.nix`, `user.nix`, `networking.nix`, `stylix.nix`, etc.
- `dev/` -- Development tools (git, jj, zsh, starship, nvim, android, godot)
- `media/` -- Audio (pipewire), graphics, gaming, music, printing, syncthing
- `security/` -- Firewall, doas, SSH, wallet

Host-specific module sets:
- `modules/hacking/` -- Security tools (wireshark, nmap, hashcat, SDR), imported by foxglove and wisteria
- `modules/server/` -- Self-hosted services, imported only by hemlock:
  - `caddy.nix` -- Reverse proxy with virtual hosts for multiple domains
  - `authelia.nix` -- SSO/MFA with LDAP backend
  - `lldap.nix`, `radicale.nix`, `immich.nix`, `headscale.nix`, `ntfy.nix`

### Home Manager

Desktop hosts (foxglove, wisteria) have a `home.nix` that imports `../../home` for the Hyprland desktop environment (waybar, alacritty, librewolf, dunst, hyprlock, hypridle). Hemlock and ivy are headless and have no home config.

### Secrets Management

Uses **sops-nix** with age encryption derived from SSH host keys. Secrets are stored encrypted in `secrets/<hostname>.yaml` and decrypted at NixOS activation time. Key mapping is in `.sops.yaml`.

## Key Patterns

- The `mkSystem` helper in `nixos/default.nix` automatically wires up disko, stylix, nixvim, sops-nix, home-manager, and custom flakes for each host
- Home Manager is conditionally enabled only when `nixos/<hostname>/home.nix` exists
- `hostname` is passed as a `specialArgs` attribute, available in all modules
- Ivy (Raspberry PI) has a separate config path using `nixos-hardware` instead of the standard `mkSystem`
- `modules/default.nix` is for shared desktop configuration; server-only modules live in `modules/server/` and are imported directly by hemlock's `configuration.nix`
