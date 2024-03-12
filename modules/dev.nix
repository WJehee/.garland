{ pkgs, ... }: {
    virtualisation.libvirtd.enable = true;
    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [
        git
        docker
        docker-compose
        nil
        just
        texlab

        act         # Github actions locally
    
        # Temporary for a course
        vscode
        zulu
    ];
}
