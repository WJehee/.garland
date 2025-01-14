{ pkgs, ... }: {
    imports = [
        ./nvim
        # ./starship.nix
        ./zsh.nix
    ];
    virtualisation = {
        libvirtd.enable = true;
        docker.enable = true;
    };
    environment.systemPackages = with pkgs; [
        git
        # jj
        docker
        docker-compose
        just
        nurl
        ghostty

        nushellPlugins.query
    ];
}
