{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        crush
        claude-code
    ];
}
