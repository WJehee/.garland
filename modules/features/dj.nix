{
    flake.modules.nixos.dj = { pkgs, ... }: {
        environment.systemPackages = [
            # Mixxx has no env var for its settings dir (defaults to ~/.mixxx),
            # only a flag; the .desktop file resolves `mixxx` via PATH so it
            # picks up this wrapper too.
            (pkgs.symlinkJoin {
                name = "mixxx-xdg";
                paths = [ pkgs.mixxx ];
                nativeBuildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                    rm $out/bin/mixxx
                    makeWrapper ${pkgs.mixxx}/bin/mixxx $out/bin/mixxx \
                        --add-flags '--settings-path "''${XDG_DATA_HOME:-$HOME/.local/share}/mixxx"'
                '';
            })
        ];
    };
}
