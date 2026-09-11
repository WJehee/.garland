{
    flake.modules.nixos.workstation = { pkgs, ... }: {
        networking.networkmanager.plugins = with pkgs; [
            networkmanager-openvpn
        ];
        services.mullvad-vpn.enable = true;
        environment.systemPackages = with pkgs; [
            openvpn
        ];
    };
}
