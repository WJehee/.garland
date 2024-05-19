{ pkgs, ... }: {
    virtualisation.libvirtd.enable = true;
    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [
        git
        docker
        docker-compose
        just
        nurl

        texlab
        nil
        vscode-langservers-extracted
        htmx-lsp
    ];
}
