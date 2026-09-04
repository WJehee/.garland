{
    flake.modules.nixos.workstation = { config, pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            clinfo
        ];
        hardware.graphics = {
            enable = true;
            enable32Bit = true;
        };
        boot = {
            plymouth.enable = true;
            kernelParams = [
                "quiet"
                "splash"
            ];
        };

        xdg.portal = {
            enable = true;
            extraPortals = [
                pkgs.xdg-desktop-portal-gtk
                pkgs.xdg-desktop-portal-hyprland
            ];
        };
        programs.hyprland = {
            enable = true;
        };
        # Log in straight into Hyprland; unlike lightdm, greetd does not
        # redirect the session's output to ~/.xsession-errors
        services.greetd = {
            enable = true;
            settings.default_session = {
                # start-hyprland (not the bare Hyprland binary) is the
                # supported entry point since 0.56; it sets up the session
                # environment the compositor expects
                command = "${config.programs.hyprland.package}/bin/start-hyprland";
                user = "wouter";
            };
        };
    };
}
