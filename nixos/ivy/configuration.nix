{ ... }: {
    imports = [
        ../../modules/home-assistant.nix
        ../../modules/server/headless.nix
    ];
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
        initrd.luks.devices.nixos = {
            device = "TODO";
            preLVM = true;
        };
    };
    networking = {
        interfaces.end0 = {
            ipv4.addresses = [{
                address = "192.168.1.42";
                prefixLength = 24;
            }];
        };
        defaultGateway = {
            address = "192.168.1.1";
            interface = "end0";
        };
        nameservers = [
            "192.168.1.1"
        ];
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
