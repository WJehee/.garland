{
    flake.modules.homeManager.dev = {
        # User level default provider for secretspec; projects only declare
        # which secrets they need in secretspec.toml.
        xdg.configFile."secretspec/config.toml".text = ''
            [defaults]
            provider = "sops://secrets.enc.yaml"
            # provider = "dotenv"
            # provider = "kdbx:/home/wouter/Sync/passwords.kdbx"
            profile = "default"
        '';
    };
}
