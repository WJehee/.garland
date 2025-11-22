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
}
