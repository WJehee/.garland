{ pkgs, ... }: {
    virtualisation.libvirtd.enable = true;
    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [
        git
        docker
        docker-compose
        just
        texlab
        nil
        nurl
        vscode-langservers-extracted
        htmx-lsp

        act         # Github actions locally
    ];
}
