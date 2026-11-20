# Declarative NetworkManager profile for the home wifi, for headless hosts
# that cannot be given the password interactively.
#
# Secrets, add with `just secrets <host>`:
#   wifi-env: a dotenv blob holding the network name and password of the
#             home wifi, as a YAML block scalar:
#               wifi-env: |
#                   WIFI_SSID=<network name>
#                   WIFI_PSK=<wifi password>
#             NetworkManager substitutes both variables into the profile
#             below.
{
    flake.modules.nixos.wifi = { config, lib, ... }: {
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
