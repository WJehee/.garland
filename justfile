alias r := rebuild
alias u := update

_default:
    just --list

# Rebuild OS
rebuild:
    sudo nixos-rebuild switch --sudo --flake . &>rebuild.log || grep -C 2 --color error rebuild.log

# Update packages
update:
    nix flake update

# Show size of current closure
size:
    nix path-info -Sh /run/current-system/

# Delete generations older than 14 days
cleanup days='14':
    doas nix-collect-garbage --delete-older-than {{days}}d

# Edit encrypted secrets for a host
secrets host=`hostname`:
    nix run nixpkgs#sops -- secrets/{{host}}.yaml

# Build SD image of a host
build-sd host:
    nix run nixpkgs#nixos-generators -- -f sd-aarch64 --flake ".#{{host}}" --system aarch64-linux -o "./{{host}}.sd"

# Remotely install a flake
remote-install flake conn_str:
    nix run github:nix-community/nixos-anywhere -- --flake ./#{{flake}} --target-host {{conn_str}} --generate-hardware-config nixos-generate-config ./hosts/{{flake}}/hardware-configuration.nix

# If home manager does activation does not work
fix:
    doas -u wouter nix-env -iE 'p: {}'

# View home manager logs
hm-logs:
    journalctl -xe --unit home-manager-wouter

