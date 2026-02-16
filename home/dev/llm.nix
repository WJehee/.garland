{ ... }: {
    programs.opencode = {
        enable = true;
        skills = {};
    };
    programs.claude-code = {
        enable = true;
        skills = {};
        memory.text = ''
            # Version control
            I use jj (Jujutsu) as my version control system, backed by git.
            Always use jj commands instead of git commands whenever possible.
            For example, use `jj status` instead of `git status`, `jj log` instead of `git log`, etc.
            
            # Writing
            When writing, please do not use em dashes.
        '';
    };
}
