{
    flake.modules.nixos.workstation = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            ledger-live-desktop
            trezor-suite
        ];
        hardware.ledger.enable = true;
        services.trezord.enable = true;
        services.pcscd.enable = true;
    };
}
