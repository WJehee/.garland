# Local model server. Kept apart from nixos.llm (the LiteLLM gateway and
# Open WebUI) so a host can serve models without the gateway; nixos.llm
# imports this module, as Ollama is its only model source.
{
    flake.modules.nixos.ollama = { config, pkgs, ... }: {
        services.ollama = {
            enable = true;
            # CUDA when the host imports gpu/nvidia, the default build
            # otherwise.
            # Chosen via package, not services.ollama.acceleration, which
            # nixpkgs deprecated in favour of the package variants.
            package =
                if builtins.elem "nvidia" config.services.xserver.videoDrivers
                then pkgs.ollama-cuda
                else pkgs.ollama;
        };
    };
}
