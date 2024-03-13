{ pkgs, ... }: {
    imports = [
	    ../../modules/default.nix
        ../../modules/pentest.nix
        ../../modules/borg.nix
    ];
    boot.initrd.luks.devices.nixos = {
        device = "/dev/disk/by-uuid/79f8374d-c878-442c-acd0-88f474dda0d6";
        preLVM = true;
    };
    environment.systemPackages = [
        pkgs.fetchFromGitHub {
            owner = "WJehee";
            repo = "loodsenboekje.com";
            rev = "0d0a81f74c3faadb399531c8e2551e1dab32c849";
            hash = "sha256-9eKd5i/LJSmLZKg/sF0O4hlkh6vrB2PKQjYSGqHtHL8=";
        }
    ];
    systemd.services.loodsenboekje = {
        serviceConfig = {
            Type = "simple";
            User = "wouter";
            ExecStart = "";
            ExecStop =  "";
            StateDirectory = "loodsenboekje";
        };
    };
}
