# NixOS configuration

Thanks to:
- [Misterio77](https://github.com/Misterio77)
- [Notusknot](https://github.com/notusknot)
- [Akirak](https://github.com/akirak)
- [Luc Perkins](https://github.com/the-nix-way)

## Installing

Create the password for full disk encryption: `echo "MY_PASSWORD" > /tmp/secret.key`

Using my [custom installer image](), one can run:  
`custom-install HOSTNAME PATH_TO_DISK`

After the install has finished, do the following:  
```sh
nixos-enter --root /mnt
passwd USERNAME
reboot
```

## Templates

Creating a new project is easy with templates:

1. Create a folder with the name of your project
2. Initialize your project with a `flake.nix` using one of the templates in `templates/default.nix` using the following command:

```
nix flake init -t github:wjehee/.dotfiles-nix#TEMPLATE
```

3. Follow the welcome instructions

### Currently available templates

- Rust
- Zig
- Elixir
- Python
- Gleam

## Server

These files also include the configuration for my personal web server,
which can be found under `hosts/rusty-server/`.

