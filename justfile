alias r := rebuild
alias u := update

hostname := `hostname`

# Rebuild OS
rebuild:
    git add .
    # Old version, this should work but there is some doas stuff: https://github.com/WJehee/.dotfiles-nix/issues/31
    # doas nixos-rebuild switch --flake ".#{{hostname}}" &>rebuild.log || grep -C 2 --color error rebuild.log
    sudo nixos-rebuild switch --use-remote-sudo --flake ".#{{hostname}}" &>rebuild.log || grep -C 2 --color error rebuild.log

# Update packages
update:
    nix flake update

# If home manager does activation does not work
fix:
    nix-env -iE 'p: {}'

