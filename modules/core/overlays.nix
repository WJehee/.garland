{ ... }: {
    nixpkgs.overlays = [
        # TODO: temporary fix -- remove this overlay once nixpkgs adds setuptools-scm
        # to uefi-firmware-parser's build-system.
        #
        # uefi-firmware-parser 1.16 (pulled in by binwalk) switched to setuptools-scm
        # upstream, but the nixpkgs derivation never added it to build-system, so the
        # wheel build fails with "Missing dependencies: setuptools-scm>=8.0".
        # SETUPTOOLS_SCM_PRETEND_VERSION avoids setuptools-scm needing a .git dir.
        (final: prev: {
            pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                (pyfinal: pyprev: {
                    uefi-firmware-parser = pyprev.uefi-firmware-parser.overridePythonAttrs (old: {
                        build-system = (old.build-system or []) ++ [ pyfinal.setuptools-scm ];
                        env = (old.env or {}) // {
                            SETUPTOOLS_SCM_PRETEND_VERSION = old.version;
                        };
                    });
                })
            ];
        })
    ];
}
