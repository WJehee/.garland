{ pkgs, ... }: {
    imports = [
        ./godot.nix
        ./nvim
        ./starship.nix
        ./zsh.nix
    ];
    virtualisation = {
        libvirtd.enable = true;
        docker.enable = true;
    };
    environment.systemPackages = with pkgs; [
        git
        jujutsu
        docker
        docker-compose
        just
        nurl
        tokei

        nushellPlugins.query
    ];
}
