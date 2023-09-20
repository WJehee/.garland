{ inputs, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        git
    ];
    serices.nginx = {
        enable = true;
    };
    services.radicale = {
        enable = true;
    };
    services.stalwart-mail = {
        enable = true;
    };
}
