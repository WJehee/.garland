# Public SSH keys referenced from more than one module. The underscore prefix
# keeps import-tree from loading this as a module; consumers `import ./_ssh-keys.nix`
# relative to their own location.
{
    # FIDO2 resident credential on the daily Nitrokey 3, touch required. It is
    # also the signing key for git and jj, see modules/features/nitrokey.nix.
    nitrokey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFW4i+isSlEKIpdABWoTsKlW5JtBkkiIzkVPYGbn0u7KAAAABHNzaDo= wouter@nitrokey-1";

    # Same on the second Nitrokey, kept as a backup in case the first is lost.
    # It is accepted everywhere the primary is, but nothing signs with it.
    nitrokey-backup = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDjzaRRE1Oir8kfwPjGHQibGCjE5Nb73PNtZTkXKgf5jAAAABHNzaDo= wouter@nitrokey-2";
}
