alias r := rebuild
alias u := update

hostname := `hostname`

# Rebuild OS
rebuild:
    git add .
    doas nixos-rebuild switch --flake ".#{{hostname}}" &>nixos-switch.log || grep -C 2 --color error nixos-switch.log

# Update packages
update:
    nix flake update

