{
    flake.modules.nixos.wifi = { config, lib, ... }: {
        # WIFI_SSID and WIFI_PSK, stored as a dotenv blob in the host's
        # sops file (edit with `just secrets <host>`)
        sops.secrets.wifi-env = { };
        networking.networkmanager.ensureProfiles = {
            environmentFiles = [ config.sops.secrets.wifi-env.path ];
            profiles.home = {
                connection = {
                    id = "home";
                    type = "wifi";
                    autoconnect = true;
                };
                wifi = {
                    mode = "infrastructure";
                    ssid = "$WIFI_SSID";
                };
                wifi-security = {
                    key-mgmt = "wpa-psk";
                    psk = "$WIFI_PSK";
                };
                # mkDefault so hosts can override with a static address
                ipv4.method = lib.mkDefault "auto";
                ipv6.method = lib.mkDefault "auto";
            };
        };
    };
}
