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

        act         # Github actions locally
    
        # Temporary for a course
        vscode
        zulu
    ];
}
