{ lib, pkgs, ... }: {
    services.tailscale.enable = true;
    services.openssh.enable = true;
    programs.ssh = {
        startAgent = true;
        enableAskPassword = true;
        askPassword = lib.mkForce "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    };
}
