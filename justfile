alias r := rebuild
alias u := update

hostname := `hostname`

# Rebuild OS
rebuild:
    git add .
    sudo nixos-rebuild switch --sudo --flake ".#{{hostname}}" &>rebuild.log || grep -C 2 --color error rebuild.log

# Update packages
update:
    nix flake update

# If home manager does activation does not work
fix:
    doas -u wouter nix-env -iE 'p: {}'

# view home manager logs
hm-logs:
    journalctl -xe --unit home-manager-wouter

# Delete generations older than 30 days
cleanup:
    doas nix-collect-garbage --delete-older-than 30d

# Build SD image of a host
build-sd host:
    git add .
    nix run nixpkgs#nixos-generators -- -f sd-aarch64 --flake ".#{{host}}" --system aarch64-linux -o "./{{host}}.sd"

# Remotely install a flake
remote-install flake conn_str:
    nix run github:nix-community/nixos-anywhere -- --flake ./#{{flake}} --target-host {{conn_str}} --generate-hardware-config nixos-generate-config ./nixos/{{flake}}/hardware-configuration.nix

