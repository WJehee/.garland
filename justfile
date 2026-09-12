alias r := rebuild
alias u := update

_default:
    just --list

# Rebuild OS (always pulls the latest pushed wreath first)
rebuild:
    nix flake update wreath
    nixos-rebuild switch --sudo --flake . &>rebuild.log || grep -C 4 --color error rebuild.log

# Rebuild against a local wreath checkout (edit private modules without pushing)
rebuild-wreath wreath='/home/wouter/.wreath':
    nixos-rebuild switch --sudo --flake . --override-input wreath path:{{wreath}} &>rebuild.log || grep -C 4 --color error rebuild.log

# Update packages
update:
    nix flake update

# Show size of current closure
size:
    nix path-info -Sh /run/current-system/

# Delete generations older than 14 days
cleanup days='14':
    doas nix-collect-garbage --delete-older-than {{days}}d
    rm -rf ~/.cache/nix/

# Edit encrypted secrets for a host
secrets host=`hostname`:
    nix run nixpkgs#sops -- secrets/{{host}}.yaml

# Build SD image of a host
build-sd host:
    nix run nixpkgs#nixos-generators -- -f sd-aarch64 --flake ".#{{host}}" --system aarch64-linux -o "./{{host}}.sd"

# Remotely install a flake
remote-install flake conn_str:
    nix run github:nix-community/nixos-anywhere -- --flake ./#{{flake}} --target-host {{conn_str}} --generate-hardware-config nixos-generate-config ./modules/hosts/{{flake}}/_hardware-configuration.nix

# Escape hatches: --boot (activate on next reboot), --dry-activate (copy and
# test only), --magic-rollback false / --auto-rollback false, or ssh in and
# run `just r` by hand.
# Deploy a host with deploy-rs (build locally, activate remotely, auto-rollback).
deploy host="hemlock":
    nix run nixpkgs#deploy-rs -- .#{{host}} --skip-checks

# If home manager does activation does not work
fix:
    doas -u wouter nix-env -iE 'p: {}'

# View home manager logs
hm-logs:
    journalctl -xe --unit home-manager-wouter

