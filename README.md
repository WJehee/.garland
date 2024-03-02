# NixOS configuration

Thanks to:
- [Misterio77](https://github.com/Misterio77) for their awesome tools and dotfiles
- [Notusknot](https://github.com/notusknot) for their [dotfiles](https://github.com/notusknot/dotfiles-nix)
- [Akirak](https://github.com/akirak) for their [templates](https://github.com/akirak/flake-templates)

See [install.md](INSTALL.md) for installation instructions.

## Templates

Creating a new project is easy with templates:

1. Create a folder with the name of your project
2. Initialize your project with a `flake.nix` using one of the templates in `templates/default.nix` using the following command:

```
nix flake init -t github:wjehee/.dotfiles-nix#TEMPLATE
```

3. Follow the welcome instructions

### Currently available templates

- rust
- zig
- elixir
- python

## Server

These files also include the configuration for my personal web server,
which can be found under `hosts/rusty-server/`.

