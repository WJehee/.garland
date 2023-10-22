alias r := rebuild

hostname := `hostname`

# Rebuild OS
rebuild:
    git add .
    doas nixos-rebuild switch --flake ".#{{hostname}}"

# Update packages
update:
    nix flake update

