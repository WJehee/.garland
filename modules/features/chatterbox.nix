{
    flake.modules.nixos.chatterbox = { config, pkgs, lib, ... }: let
        # OpenAI compatible TTS API around Resemble AI's Chatterbox model
        src = pkgs.fetchFromGitHub {
            owner = "travisvn";
            repo = "chatterbox-tts-api";
            rev = "a5f466128e4baa8e4cceb3bba9b7ca9de6f7ec6b";
            hash = "sha256-yHrUZsmtCjxlEsajbYU3fQpTSepAXJiOfv8cEiolfV4=";
        };
        # Use CUDA when the host imports gpu/nvidia, cpu-only torch otherwise
        cuda = builtins.elem "nvidia" config.services.xserver.videoDrivers;
    in {
        systemd.services.chatterbox = {
            description = "Chatterbox TTS API server";
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            path = with pkgs; [ uv git ffmpeg gcc ];

            environment = {
                HOST = "127.0.0.1";
                PORT = "4123";
                DEVICE = if cuda then "cuda" else "cpu";
                VOICE_SAMPLE_PATH = "${src}/voice-sample.mp3";
                MODEL_CACHE_DIR = "/var/lib/chatterbox/models";
                VOICE_LIBRARY_DIR = "/var/lib/chatterbox/voices";
                LONG_TEXT_DATA_DIR = "/var/lib/chatterbox/long-text-jobs";
                HF_HOME = "/var/lib/chatterbox/huggingface";
                HF_HUB_DISABLE_TELEMETRY = "true";

                PYTHONDONTWRITEBYTECODE = "1";
                VIRTUAL_ENV = "/var/lib/chatterbox/venv";
                UV_CACHE_DIR = "/var/lib/chatterbox/uv-cache";
                UV_PYTHON = lib.getExe pkgs.python311;
                UV_PYTHON_DOWNLOADS = "never";
                # pip wheels expect FHS system libraries; the service environment
                # does not go through nix-ld, so provide them directly.
                # libcuda.so comes from the host driver, not the pip wheels
                LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [
                    stdenv.cc.cc.lib
                    zlib
                    libsndfile
                ]) + lib.optionalString cuda ":/run/opengl-driver/lib";
            };

            # Dependency install mirrors the project's Dockerfiles: torch first
            # (cpu-only wheels unless the host has an NVIDIA GPU), then the rest.
            # The venv marker includes the torch flavor so switching between
            # cpu and cuda rebuilds the venv
            script = let
                torchInstall = if cuda
                    then ''uv pip install "torch<2.7" "torchaudio<2.7"''
                    else ''uv pip install "torch<2.7" "torchaudio<2.7" --index-url https://download.pytorch.org/whl/cpu'';
                venvMarker = "${src}:${if cuda then "cuda" else "cpu"}";
            in ''
                if [ "$(cat .venv-for 2>/dev/null)" != "${venvMarker}" ]; then
                    rm -rf "$VIRTUAL_ENV"
                    uv venv "$VIRTUAL_ENV"
                    ${torchInstall}
                    uv pip install fastapi "uvicorn[standard]" python-dotenv python-multipart requests psutil pydub sse-starlette resemble-perth
                    uv pip install "git+https://github.com/travisvn/chatterbox-multilingual.git@exp"
                    echo "${venvMarker}" > .venv-for
                fi
                exec "$VIRTUAL_ENV/bin/python" ${src}/main.py
            '';

            serviceConfig = {
                DynamicUser = true;
                StateDirectory = "chatterbox";
                WorkingDirectory = "/var/lib/chatterbox";
                Restart = "on-failure";
            };
        };
    };
}
