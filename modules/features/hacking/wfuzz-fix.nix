{
    flake.modules.nixos.hacking = {
        nixpkgs.overlays = [
            # TODO: temporary fix -- remove once nixpkgs' wfuzz is patched for the
            # pkg_resources removal (or upstream wfuzz drops it). Then `just update`
            # is enough and this can be deleted.
            #
            # nixpkgs bumped setuptools to 82.x, which no longer ships the legacy
            # `pkg_resources` module. wfuzz 3.1.1 still does `import pkg_resources`
            # in helpers/file_func.py, so its pythonImportsCheck dies with
            # `ModuleNotFoundError: No module named 'pkg_resources'`, which in turn
            # breaks the `wordlists` collection (wfuzz is one of its `lists`).
            #
            # The only use is resolving the bundled advanced.rst help file, so swap
            # it for the stdlib importlib.resources equivalent. replace-fail errors
            # out if either string ever changes upstream, so this can't silently rot.
            (final: prev: {
                wfuzz = prev.wfuzz.overrideAttrs (old: {
                    postPatch = (old.postPatch or "") + ''
                        substituteInPlace src/wfuzz/helpers/file_func.py \
                            --replace-fail 'import pkg_resources' 'import importlib.resources' \
                            --replace-fail 'pkg_resources.resource_filename("wfuzz", FILTER_HELP_FILE)' 'str(importlib.resources.files("wfuzz").joinpath(FILTER_HELP_FILE))'
                    '';
                });
            })
        ];
    };
}
