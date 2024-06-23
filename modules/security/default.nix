{ ... }: {
    imports = [
        ./firewall.nix
        ./doas.nix
        ./ssh.nix
    ];
}
