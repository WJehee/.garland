# Terminal agent harnesses next to Claude Code: goose, hermes and herdr (a
# terminal multiplexer for running several agents side by side). Goose and
# hermes run sandboxed exactly like claude (./_sandbox.nix), each with its
# own persistent sandbox home under XDG_DATA_HOME; herdr runs on the host,
# since it only multiplexes terminals and starts the sandboxed agents.
#
# Both agents talk to the LiteLLM gateway of nixos.llm: on the host that runs
# it over the container's loopback, which pasta forwards to the host's; on
# every other workstation over the home LAN at wisteria.local. The container
# resolves no mDNS, so the wrapper resolves that name on the host (avahi nss,
# enabled below) and pins it into the container's /etc/hosts.
#
# The wrappers export LITELLM_HOST and LITELLM_API_KEY, the key read at launch
# from the secret below, so it never lands in the store or the session
# environment. Goose picks the litellm provider up from these variables
# directly. Hermes keeps its provider choice in its own mutable
# ~/.hermes/config.yaml (in its sandbox home), so it is pointed at the
# gateway once with `hermes setup`, choosing the custom provider with base
# URL `$LITELLM_HOST/v1` and key env `LITELLM_API_KEY`.
#
# Secrets, add with `just secrets <host>`:
#   litellm-master-key: the same value as in secrets/wisteria.yaml, see
#                       modules/features/llm.nix.
#
# In the context of a single-user home network, facing LiteLLM without a
# database (so no per-client virtual keys), we chose to hand the agents the
# master key to keep the gateway stateless, accepting that any agent can
# administer it.
{ inputs, ... }: let
    # The host whose nixos.llm the other workstations use. Changing it means
    # importing nixos.llm there instead.
    gatewayHost = "wisteria";
    # Must match services.litellm.port in modules/features/llm.nix
    gatewayPort = 4141;
in {
    flake.modules.nixos.dev = {
        sops.secrets."litellm-master-key".owner = "wouter";
        services.avahi = {
            enable = true;
            nssmdns4 = true;
        };
    };

    flake.modules.homeManager.dev = { config, lib, pkgs, osConfig, ... }: let
        mkSandbox = import ./_sandbox.nix { inherit config lib pkgs osConfig; };
        localGateway = osConfig.services.litellm.enable;
        port = toString gatewayPort;

        withGateway = args: mkSandbox (args // {
            env = {
                LITELLM_HOST =
                    if localGateway
                    then "http://127.0.0.1:${port}"
                    else "http://${gatewayHost}.local:${port}";
            } // args.env or {};
            secretEnv.LITELLM_API_KEY = osConfig.sops.secrets."litellm-master-key".path;
            preRun = if localGateway then ''
                # -T forwards the port from the container's loopback to the
                # host's, leaving the rest of the host's loopback unreachable
                extra+=(--network "pasta:-T,${port}")
            '' else ''
                # Unresolvable (away from home) just leaves the agent
                # without a gateway
                if read -r ip _ < <(${pkgs.getent}/bin/getent ahostsv4 ${gatewayHost}.local); then
                    extra+=(--add-host "${gatewayHost}.local:$ip")
                fi
            '';
        });
    in {
        home.packages = [
            pkgs.herdr
            (withGateway {
                name = "goose";
                program = lib.getExe pkgs.goose-cli;
                env = {
                    GOOSE_PROVIDER = "litellm";
                    # Must match a model_name in nixos.llm's model_list
                    GOOSE_MODEL = "local-qwen-coder";
                    # No secret service in the container; goose would fail
                    # to open the keyring, and the key comes from the
                    # environment anyway
                    GOOSE_DISABLE_KEYRING = "1";
                };
            })
            (withGateway {
                name = "hermes";
                program = lib.getExe inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
            })
        ];
    };
}
