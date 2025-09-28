{ ... }: {
    programs = {
        nushell = {
            enable = true;
            configFile.text = ''
                $env.config = {
                    show_banner: false,
                }

            '';
            envFile.text = ''
                $env.STARSHIP_SHELL = "nu"

                def create_left_prompt [] {
                    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
                }

                $env.PROMPT_COMMAND = { || create_left_prompt }
                $env.PROMPT_COMMAND_RIGHT = ""

                $env.PROMPT_INDICATOR = ""
                $env.PROMPT_INDICATOR_VI_INSERT = ": "
                $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
                $env.PROMPT_MULTILINE_INDICATOR = "::: "
            '';
            shellAliases = {
                la = "ls -a";
                nd = "nix develop -c $STARSHIP_SHELL";
            };
        };
        carapace = {
            enable = true;
            enableNushellIntegration = true;
        };
    };
}
