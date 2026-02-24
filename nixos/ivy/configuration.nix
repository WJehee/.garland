{ config, ... }: {
    imports = [
        # Default configs
        ../../modules
        ../../modules/dev
        ../../modules/server/headless.nix

        # Specific configs
        ../../modules/home-assistant.nix
    ];
    system.stateVersion = "24.11";
    nix.settings = {
        trusted-users = [
            "admin"
        ];
        experimental-features = [
            "nix-command"
            "flakes"
        ];
    };
    boot = {
        loader = {
            grub.enable = false;
            generic-extlinux-compatible.enable = true;
        };
    };
    environment.variables = {
        SHELL = "zsh";
        EDITOR = "neovim";
    };
}
