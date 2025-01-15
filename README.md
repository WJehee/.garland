# NixOS configuration

Thanks to:
- [Misterio77](https://github.com/Misterio77)
- [Notusknot](https://github.com/notusknot)
- [Akirak](https://github.com/akirak)
- [Luc Perkins](https://github.com/the-nix-way)
- [Gaétan Lepage](https://github.com/GaetanLepage)

## Installing

Using my [custom installer image](https://github.com/WJehee/nixos-installer)

1. Become root `sudo su`
2. Create the password for full disk encryption: `echo "MY_PASSWORD" > /tmp/secret.key`
3. `disko-format /PATH/TO/DISK`
4. `install-flake HOSTNAME`
5. Set root passwd after being prompted

After the install has finished, do the following:  
```sh
nixos-enter --root /mnt
passwd USERNAME
exit
reboot
```
## Installing custom packages

You can build any packages in `pkgs/`, by running `nix build .#PACKAGE_NAME`  
You can install it into your profile by running `nix profile .#PACKAGE_NAME`

## Server

These files also include the configuration for my personal web server,
which can be found under `nixos/rusty-server/`.

# Notes

Old version of rebuild command, this should work but there is some doas stuff: https://github.com/WJehee/.dotfiles-nix/issues/31

`doas nixos-rebuild switch --flake ".#{{hostname}}" &>rebuild.log || grep -C 2 --color error rebuild.log`

