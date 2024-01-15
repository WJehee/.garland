alias r := rebuild
alias u := update

hostname := `hostname`

# Rebuild OS
rebuild:
    git add .
    doas nixos-rebuild switch --flake ".#{{hostname}}"

# Update packages
update:
    doas nix flake update

# Mount borg backup
mount:
    doas borg-job-borgbase mount ssh://b49ad843@b49ad843.repo.borgbase.com/./repo /root/borg/mount    

# Unmount borg backup
unmount:
    doas borg-job-borgbase umount /root/borg/mount

