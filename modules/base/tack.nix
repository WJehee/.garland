# tack pins this repo's flake inputs (.tack/pins.toml); `just update` runs it.
# Installed on every host because any of them can run `just` from a checkout.
{
    flake.modules.nixos.base = {
        programs.tack.enable = true;
    };
}
