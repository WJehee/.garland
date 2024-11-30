{ pkgs, ... }: {
    imports = [
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
        docker
        docker-compose
        just
        nurl

        texlab
        nixd

        nushellPlugins.query
    ];
}
