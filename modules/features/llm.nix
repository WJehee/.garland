# LLM gateway and chat UI: LiteLLM puts the local Ollama models behind a
# single OpenAI compatible endpoint; Open WebUI and the agents in
# modules/dev/agents.nix talk to that endpoint only. Importing this module
# imports nixos.ollama too, since without it the gateway has no models.
#
# Secrets, add with `just secrets <host>`:
#   litellm-master-key: generated, `echo "sk-$(openssl rand -hex 32)"`. It is
#                       the admin key of the LiteLLM endpoint and the key
#                       Open WebUI and the agents authenticate with. LiteLLM
#                       rejects master keys that do not start with `sk-`.
{ config, ... }: let
    nixos = config.flake.modules.nixos;
in {
    flake.modules.nixos.llm = { config, lib, ... }: let
        ollama = config.services.ollama;
        # LiteLLM model name -> ollama library tag. qwen3-coder is the one
        # meant for the agents (modules/dev/agents.nix): it handles tool calls,
        # which llama3.2 at 3B does not do reliably.
        localModels = {
            local-llama = "llama3.2";
            local-qwen-coder = "qwen3-coder";
        };
    in {
        imports = [ nixos.ollama ];

        # Also declared, readable by the user, by modules/dev/agents.nix on
        # every host importing nixos.dev
        sops.secrets."litellm-master-key" = {};
        sops.templates."litellm.env".content = ''
            LITELLM_MASTER_KEY=${config.sops.placeholder."litellm-master-key"}
        '';
        sops.templates."open-webui.env".content = ''
            OPENAI_API_KEY=${config.sops.placeholder."litellm-master-key"}
        '';

        # Pulled at boot, so every model LiteLLM advertises exists
        services.ollama.loadModels = lib.attrValues localModels;

        # Reachable from the other workstations (modules/dev/agents.nix) under
        # <hostname>.local. The whole LAN can connect; every request still
        # needs the master key. Open WebUI stays on localhost.
        networking.firewall.allowedTCPPorts = [ config.services.litellm.port ];
        services.avahi = {
            enable = true;
            settings.publish = {
                disable-publishing = false;
                publish-addresses = true;
            };
        };

        services.litellm = {
            enable = true;
            host = "0.0.0.0";
            # modules/dev/agents.nix hardcodes this port for remote hosts
            port = 4141;
            environmentFile = config.sops.templates."litellm.env".path;
            settings = {
                model_list = lib.mapAttrsToList (name: model: {
                    model_name = name;
                    # ollama_chat/ (the /api/chat endpoint) rather than
                    # ollama/ (/api/generate), which drops tool calls and
                    # so breaks the agents
                    litellm_params = {
                        model = "ollama_chat/${model}";
                        api_base = "http://${ollama.host}:${toString ollama.port}";
                    };
                }) localModels;
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
