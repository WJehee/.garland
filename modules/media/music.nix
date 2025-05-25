{ pkgs, inputs, ... }: {
    environment.systemPackages = with pkgs; [
        spotify
        ncspot
    ];
}
