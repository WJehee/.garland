{ config, ... }: {
    imports = [
        ../../modules/sops.nix
        ../../modules/server/headless.nix
        ../../modules/home-assistant.nix
        ../../modules/tailscale.nix
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
    networking = {
        hostName = "ivy";
        networkmanager.enable = true;
        firewall.enable = false;
    };
    environment.variables = {
        SHELL = "zsh";
        EDITOR = "neovim";
    };
    programs.zsh.enable = true;
    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        configure.customRC = ''
            set expandtab
            set tabstop=4
            set softtabstop=4
            set shiftwidth=4
        '';
    };
}
