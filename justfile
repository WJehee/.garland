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

# Extra deploy-rs flags pass through after the host name: --boot (activate on
# next reboot), --dry-activate (copy and test only), --magic-rollback false /
# --auto-rollback false. Or ssh in and run `just r` by hand.
# The flake ref is path:. rather than . because the repo is a colocated jj
# checkout, which nix always reports as a dirty git tree.
# Deploy a host with deploy-rs: build on the host itself, activate, auto-rollback.
deploy host="hemlock" *flags="":
    nix run nixpkgs#deploy-rs -- path:.#{{host}} --skip-checks --remote-build {{flags}}

# The node config defaults to local because --remote-build can only switch remote on.
# Same, but build locally and copy the closure (when custom packages need compiling).
deploy-local host="hemlock" *flags="":
    nix run nixpkgs#deploy-rs -- path:.#{{host}} --skip-checks {{flags}}

# The audit uses vulnxscan from sbomnix, which merges vulnix, grype
# and OSV into one report. The current machine is scanned as it runs;
# any other host is evaluated from this flake and its toplevel built locally,
# so pass --buildtime for the aarch64 hosts (scans the derivation graph
# without building, at the cost of including build-time dependencies).
# Findings matching audit/whitelist.csv are hidden from the console and
# annotated in the csv; results land in audit/<host>.csv (gitignored).
# Scan a host closure for known CVEs (current machine by default)
audit host=`hostname` *flags="":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{host}}" = "$(hostname)" ]; then
        target="$(readlink -f /run/current-system)"
    else
        target="path:.#nixosConfigurations.{{host}}.config.system.build.toplevel"
    fi
    nix shell nixpkgs#sbomnix -c vulnxscan --whitelist audit/whitelist.csv -o "audit/{{host}}.csv" {{flags}} "$target"

# If home manager does activation does not work
fix:
    doas -u wouter nix-env -iE 'p: {}'

# View home manager logs
hm-logs:
    journalctl -xe --unit home-manager-wouter

