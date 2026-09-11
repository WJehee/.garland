# Rootless podman as the container engine. `docker` is an alias for podman
# and the podman socket also answers on /run/docker.sock, so tooling that
# expects the docker API keeps working (members of the podman group only).
{
    flake.modules.nixos.podman = { pkgs, ... }: {
        virtualisation.podman = {
            enable = true;
            dockerCompat = true;
            dockerSocket.enable = true;
            defaultNetwork.settings.dns_enabled = true;
        };
        environment.systemPackages = with pkgs; [
            podman-compose
        ];
    };
}
