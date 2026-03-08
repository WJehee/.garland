{ ... }: {
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
    # virtualisation.oci-containers = {
    #     backend = "docker";
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
}
