{
    flake.modules.nixos."3d-printing" = { pkgs, ... }: let
        version = "02.07.01.57";
        # Official upstream AppImage, avoids the heavy (OOM-prone) source build.
        src = pkgs.fetchurl {
            url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubuntu-24.04-v${version}-20260601192128.AppImage";
            sha256 = "0lzbz3awnzd2dhkx4a14b5h55qs4jp8x9qksrmsqf8qs7y2m7c45";
        };
        bambu-studio-fhs = pkgs.appimageTools.wrapType2 {
            pname = "bambu-studio";
            inherit version src;
            # Embedded login/webview needs webkitgtk at runtime. glib-networking
            # provides the GIO TLS backend, without which the webview reports
            # "no TLS support" and nothing from the web loads.
            extraPkgs = pkgs: with pkgs; [ webkitgtk_4_1 glib-networking ];
        };
        # The FHS `runScript` does not source /etc/profile, so buildFHSEnv's
        # `profile` env never reaches the AppImage. Wrap the launcher instead:
        # bwrap inherits this process's environment and bind-mounts /nix, so the
        # GIO_EXTRA_MODULES store path stays valid inside the sandbox and the
        # webview's network process can find the gnutls TLS backend.
        bambu-studio = pkgs.symlinkJoin {
            name = "bambu-studio-${version}";
            paths = [ bambu-studio-fhs ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
                rm $out/bin/bambu-studio
                makeWrapper ${bambu-studio-fhs}/bin/bambu-studio $out/bin/bambu-studio \
                    --set GIO_EXTRA_MODULES ${pkgs.glib-networking}/lib/gio/modules
            '';
        };
    in {
        environment.systemPackages = [ bambu-studio ];
    };
}
