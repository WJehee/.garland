{
    # Suricata: network IDS, inspecting traffic on the capture interfaces against
    # the rule sources fetched daily by the suricata-update timer. Alerts and
    # protocol metadata land in /var/log/suricata/eve.json (module default).
    #
    # The capture interface is host specific and deliberately not set here: the
    # NixOS module asserts at least one is configured, so a host importing this
    # feature must add for example
    #   services.suricata.settings.af-packet = [ { interface = "enp1s0"; } ];
    # and should narrow HOME_NET to its own networks.
    flake.modules.nixos.suricata = {
        services.suricata = {
            enable = true;
            # Reload rules in place after suricata-update instead of only picking
            # them up on the next restart.
            reloadOnRulesetUpdate = true;
            settings.vars.address-groups.HOME_NET = "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,100.64.0.0/10]";
        };
    };
}
