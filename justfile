alias r := rebuild
alias u := update

_default:
    just --list

# nom (nix-output-monitor, installed by modules/base/system.nix) renders the
# internal-json log as a build tree with progress and prints failing build
# logs itself. It falls back to nix run so the first rebuild that installs it
# works too.
# Rebuild OS
rebuild:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v nom >/dev/null; then nom=(nom); else nom=(nix run nixpkgs#nix-output-monitor --); fi
    nixos-rebuild switch --sudo --flake . --log-format internal-json -v |& "${nom[@]}" --json

# Inputs are pinned by tack (.tack/pins.toml), not by flake.lock. It falls back
# to nix run on a machine that has not yet rebuilt with modules/base/tack.nix.
# Update flake inputs (all, or only the named pins)
update *pins="":
    #!/usr/bin/env bash
    set -euo pipefail
    # Unauthenticated GitHub API calls are capped at 60 per hour per IP, which
    # a full update of this repo exhausts in about two runs; tack compares
    # github: pins through that API. The gh login is reused instead of a
    # separate token so no secret has to be stored for this.
    if [ -z "${GITHUB_TOKEN:-}" ] && command -v gh >/dev/null && token="$(gh auth token 2>/dev/null)"; then
        export GITHUB_TOKEN="$token"
    fi
    # tack reaches git+ssh pins (blotter) through gitoxide, which captures
    # ssh's stderr, so ssh announces the Nitrokey touch via its askpass. The
    # askpass would write to the terminal, where tack's progress redraw wipes
    # it; this sends it to a desktop notification (modules/features/nitrokey.nix).
    export NITROKEY_ANNOUNCE=desktop
    if command -v tack >/dev/null; then tack=(tack); else tack=(nix run nixpkgs#tack --); fi
    "${tack[@]}" update {{pins}}

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

