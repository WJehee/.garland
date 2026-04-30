{ config, ... }: {
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
                {
                    model_name = "local-llama";
                    litellm_params = {
                        model = "ollama/llama3.2";
                        api_base = "http://localhost:11434";
                    };
                }
                {
                    model_name = "local-qwen-coder";
                    litellm_params = {
                        model = "ollama/qwen2.5-coder";
                        api_base = "http://localhost:11434";
                    };
                }
            ];
            litellm_settings = {
                drop_params = true;
            };
        };
    };

    services.ollama.enable = true;

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
        };
    };
}
