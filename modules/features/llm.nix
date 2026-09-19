# LLM gateway and chat UI: LiteLLM exposes the Anthropic models and, when the
# host also imports nixos.ollama, the local ones behind a single OpenAI
# compatible endpoint; Open WebUI talks to that endpoint only.
{
    flake.modules.nixos.llm = { config, lib, ... }: let
        ollama = config.services.ollama;
        localModel = name: model: {
            model_name = name;
            litellm_params = {
                model = "ollama/${model}";
                api_base = "http://${ollama.host}:${toString ollama.port}";
            };
        };
    in {
        sops.secrets = {
            "anthropic-api-key" = {};
            "litellm-master-key" = {};
        };
        sops.templates."litellm.env".content = ''
            ANTHROPIC_API_KEY=${config.sops.placeholder."anthropic-api-key"}
            LITELLM_MASTER_KEY=${config.sops.placeholder."litellm-master-key"}
        '';
        sops.templates."open-webui.env".content = ''
            OPENAI_API_KEY=${config.sops.placeholder."litellm-master-key"}
        '';

        services.litellm = {
            enable = true;
            port = 4141;
            environmentFile = config.sops.templates."litellm.env".path;
            settings = {
                model_list = [
                    {
                        model_name = "claude-opus";
                        litellm_params = {
                            model = "anthropic/claude-opus-4-7";
                            api_key = "os.environ/ANTHROPIC_API_KEY";
                        };
                    }
                    {
                        model_name = "claude-sonnet";
                        litellm_params = {
                            model = "anthropic/claude-sonnet-4-6";
                            api_key = "os.environ/ANTHROPIC_API_KEY";
                        };
                    }
                    {
                        model_name = "claude-haiku";
                        litellm_params = {
                            model = "anthropic/claude-haiku-4-5-20251001";
                            api_key = "os.environ/ANTHROPIC_API_KEY";
                        };
                    }
                ] ++ lib.optionals ollama.enable [
                    (localModel "local-llama" "llama3.2")
                    (localModel "local-qwen-coder" "qwen2.5-coder")
                ];
                litellm_settings = {
                    drop_params = true;
                };
            };
        };

        services.open-webui = {
            enable = true;
            port = 9090;
            environmentFile = config.sops.templates."open-webui.env".path;
            environment = {
                SCARF_NO_ANALYTICS = "True";
                DO_NOT_TRACK = "True";
                ANONYMIZED_TELEMETRY = "False";
                ENABLE_OLLAMA_API = "False";
                OPENAI_API_BASE_URL = "http://127.0.0.1:4141/v1";
                WEBUI_URL = "http://localhost:9090";
                HOME = "/var/lib/open-webui";
            };
        };
    };
}
