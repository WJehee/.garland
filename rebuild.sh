git add .
doas nixos-rebuild switch --flake ".#$(hostname)"
