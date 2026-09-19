# Local model server. Kept apart from nixos.llm (the LiteLLM gateway and
# Open WebUI) so a host can run the gateway against remote APIs only, or
# serve models without the gateway. nixos.llm picks up the local models
# automatically when both are imported.
{
    flake.modules.nixos.ollama = { config, pkgs, ... }: {
        services.ollama = {
            enable = true;
            # CUDA when the host imports gpu/nvidia, the default build
            # otherwise. No rocm mapping for gpu/amd: the cards that module
            # targets are too old for rocm, and the rocm closure is huge.
            # Chosen via package, not services.ollama.acceleration, which
            # nixpkgs deprecated in favour of the package variants.
            package =
                if builtins.elem "nvidia" config.services.xserver.videoDrivers
                then pkgs.ollama-cuda
                else pkgs.ollama;
        };
    };
}
