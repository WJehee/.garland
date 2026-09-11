{
    flake.modules.nixos.home-assistant = {
        services.home-assistant = {
            enable = true;
            extraComponents = [
                # Components required to complete the onboarding
                "esphome"
                "met"
                "radio_browser"
            ];
            config = {
                default_config = {};
            };
        };
        # Ivy runs a firewall and the frontend port is no longer derivable
        # at eval time (services.home-assistant.openFirewall was removed),
        # so 8123 has to be opened by hand
        networking.firewall.allowedTCPPorts = [ 8123 ];
        # virtualisation.oci-containers = {
        #     backend = "podman";
        #     containers.homeassistant = {
        #         volumes = [
        #             "home-assistant:/config"
        #             "/var/run/dbus:/run/dbus:ro"
        #         ];
        #         environment.TZ = "Europe/Amsterdam";
        #         image = "ghcr.io/home-assistant/home-assistant:2023.7.3";
        #         extraOptions = [
        #             "--network=host"
        #         ];
        #     };
        # };
    };
}
