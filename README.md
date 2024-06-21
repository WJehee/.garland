# NixOS configuration

Thanks to:
- [Misterio77](https://github.com/Misterio77)
- [Notusknot](https://github.com/notusknot)
- [Akirak](https://github.com/akirak)
- [Luc Perkins](https://github.com/the-nix-way)

## Installing

```sh
sudo nix
--extra-experimental-features nix-command
--extra-experimental-features flakes
run 'github:nix-community/disko#disko-install' -- --flake
'github:wjehee/.dotfiles-nix#HOSTNAME' --disk main /dev/DISK_UUID
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

