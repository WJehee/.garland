{ ... }: {
    programs.opencode = {
        enable = true;
        skills = {};
    };
    programs.claude-code = {
        enable = true;
        skills = {};
        memory.text = ''
            # Projects
            All my machines run NixOS.
            All projects should include a nix flake for installing, running and building the project.

            All projects should have a simple justfile for running common commands for using in the project.
            Basic flakes to get started can be found at https://github.com/wjehee/.garland in the template sfolder.
            The link also contains the nix flake that exposes templates for most languages I use.

            I use jj (Jujutsu) as my version control system, backed by git.
            Always use jj commands instead of git commands whenever possible.
            For example, use `jj status` instead of `git status`, `jj log` instead of `git log`, etc.
            
            # Writing
            When writing, please do not use em dashes and emoji's 🙏.
        '';
    };
}
