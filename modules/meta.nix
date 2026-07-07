{ inputs, ... }: {
    # Provides the flake.modules.<class>.<name> deferredModule namespaces
    # that all feature and host files write into
    imports = [ inputs.flake-parts.flakeModules.modules ];
    systems = [
        "x86_64-linux"
        "aarch64-linux"
    ];
}
