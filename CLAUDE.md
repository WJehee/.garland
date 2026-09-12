# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Garland is a NixOS configuration repository managing these machines (named after poisonous plants):
- **foxglove** -- Framework laptop (desktop, x86_64)
- **wisteria** -- Desktop workstation (x86_64)
- **oleander** -- Dedicated desktop PC running as a homelab server: LLMs, Immich, Gitea (x86_64)
- **hemlock** -- VPS server (headless, x86_64)
- **ivy** -- Raspberry PI running Home Assistant (aarch64)
- **wormwood** -- Raspberry PI running AdGuard Home, the network DNS filter (aarch64)
- **manchineel**, **belladonna** -- stub hosts, base + server (headless), no role assigned yet

## Common Commands

```bash
just rebuild          # Rebuild NixOS (alias: just r)
just update           # Update flake inputs (alias: just u)
just secrets <host>   # Edit encrypted secrets for a host (defaults to current hostname)
just cleanup          # GC generations older than 14 days
just build-sd <host>  # Build SD image for aarch64 (Raspberry PI)
just remote-install <flake> <conn_str>  # Remote install via nixos-anywhere
just deploy <host>    # Deploy a remote host with deploy-rs, building on the host (defaults to hemlock)
just deploy-local <host>  # Same, but build locally and copy the closure (for compiling custom packages)
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

Main module names: `base` (all hosts), `workstation` (desktop bundle), `server` (headless bundle), `dev`, `hacking`, and one name per optional feature (`tailscale`, `music`, `llm`, `cad`, `osint`, `"3d-printing"`, `home-assistant`, `podman`, `virtualization`, ...). Server services are `"services/<name>"`, GPU variants `"gpu/amd"`/`"gpu/intel"`, disk layouts `"disk/luks-lvm"`/`"disk/server"`. Home-manager names: `workstation`, `hyprland`, `shell`, `dev`, `monitor-workspaces`.

### Hosts

`modules/hosts/<name>` defines `flake.modules.nixos."hosts/<name>"`: it imports the feature modules the host wants (importing a feature IS enabling it; there are no enable flags or `variables.nix`) plus host-specific config (hostname, disk/boot specifics, wallpaper, monitor layout). Home-manager users are attached there via `home-manager.users.<user>.imports`. Ivy (Raspberry PI, aarch64) is a host module like the others, just importing fewer features plus `nixos-hardware`'s raspberry-pi-3 module.

### Remote Deployment

Remote hosts are managed with **deploy-rs** (`modules/deploy.nix`). Each entry in that file's `hosts` attrset is a node: its name must match the `nixosConfiguration`, and it carries the address and `remoteBuild = false`. That flag must stay false: deploy-rs's `--remote-build` CLI flag can only switch remote building on, so the justfile adds it for `just deploy` (build on the host, reusing its store) and omits it for `just deploy-local` (build here, copy the closure; use it when custom packages such as loodsenboekje or galeharp need compiling on the faster machine). `sshUser`, `user` and `sudo` are set once at the top level of `flake.deploy`; servers use passwordless doas, so there is no `interactiveSudo`.

The same file is the single source for SSH access: `modules/base/ssh.nix` turns every deploy node into a `Host <name>` alias with the node's address and user, so `ssh hemlock` and `just deploy hemlock` always agree. Adding a node gives every host the alias.

`just deploy <host>` skips deploy-rs's pre-checks (`--skip-checks`, since they evaluate every host config, not just the target), then builds, copies, activates and rolls back automatically if activation fails or the host drops off the network. Extra deploy-rs flags pass through after the host name: `just deploy hemlock --dry-activate`, `--boot`, `--magic-rollback false`, `--auto-rollback false`; or ssh in and run `just r`. Fresh installs still go through `just remote-install` (nixos-anywhere). `deploy-schema` and `deploy-activate` are exposed as flake checks on x86_64-linux.

### Secrets Management

Uses **sops-nix** with age encryption derived from SSH host keys. Secrets are stored encrypted in `secrets/<hostname>.yaml` (path derived from `config.networking.hostName` in `modules/base/sops.nix`) and decrypted at NixOS activation time. Key mapping is in `.sops.yaml`.

## Key Patterns

- No `specialArgs` beyond `inputs`; modules read everything else from `config`
- Flake input modules are imported by the feature that configures them (e.g. `modules/base/nixvim.nix` imports `inputs.nixvim.nixosModules.nixvim`; `modules/home-manager.nix` wires up home-manager)
- Defining a `flake.modules.*` entry activates nothing by itself; orphan features (`gaming`, `opensnitch`, `"services/headscale"`, `"services/ntfy"`, `freetube`) exist as names no host currently imports
- `home.stateVersion` lives in each host file and must never change after install
- Containers run on rootless podman (`nixos.podman`); there is no docker. `docker` is an alias for podman
- When a workaround exists only because of an actively tracked upstream issue (a library, nixpkgs, a tool), mark it with a `TODO` comment that links the issue and says what to remove or revert once it is fixed upstream. Example: the monospace fallback entries in `modules/workstation/fontconfig.nix` for alacritty issue 481
- Claude Code is sandboxed: `claude` (from `modules/dev/claude-sandbox.nix`, home-manager `dev`) runs the real binary in a podman container that sees the project directory, the nix store, the nix daemon socket and the host profiles, but not the home directory. Hosts importing `hm.dev` must import `nixos.podman`

