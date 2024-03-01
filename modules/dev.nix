{ pkgs, ... }: {
    virtualisation.libvirtd.enable = true;
    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [
        git
        docker
        docker-compose
        nil
        just

        elixir
        elixir-ls
        texlab
        zig
        zls
        act         # Github actions locally

        vscode
        zulu
    ];
}
