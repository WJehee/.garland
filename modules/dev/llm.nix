{
    flake.modules.homeManager.dev = { lib, pkgs, ... }: {
        # RTK rewrites Bash tool calls via a PreToolUse hook. Registered with
        # `rtk init` (idempotent, runs on every activation including the first
        # one on a fresh install) instead of programs.claude-code.settings,
        # because the latter makes settings.json a read-only store symlink,
        # which breaks runtime edits from /config. rtk init errors if ~/.claude
        # does not exist yet, hence the mkdir.
        home.activation.rtkClaudeHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run mkdir -p "$HOME/.claude"
            run ${lib.getExe pkgs.rtk} init -g --hook-only --auto-patch --no-trust-filters
        '';

        programs.opencode = {
            enable = true;
            skills = {};
        };
        programs.claude-code = {
            enable = true;
            skills = {
                init-project = ../../skills/init-project;
            };
            context = ''
                # Projects
                All my machines run NixOS.
                All projects use devenv (devenv.nix + devenv.yaml, direnv with `use devenv`) for the development environment.
                Projects that build a distributable artifact additionally include a nix flake for building it (e.g. rust via naersk); the dev shell always comes from devenv, not the flake.

                All projects use secretspec for secrets: declarations live in secretspec.toml (committed), values in a sops encrypted secrets.enc.yaml (committed, age recipients in .sops.yaml). My default provider is configured user level via home-manager. Never put secrets in plaintext files; use `secretspec set/check/run`.

                All projects should have a simple justfile for running common commands for using in the project.
                Project templates for most languages I use live at https://github.com/wjehee/.garland in the templates folder, exposed as nix flake templates (nix flake init -t). After init, `just init` sets the project name from the directory name.

                I use jj (Jujutsu) as my version control system, backed by git.
                Always use jj commands instead of git commands whenever possible.
                For example, use `jj status` instead of `git status`, `jj log` instead of `git log`, etc.

                # Writing
                When writing, please do not use em dashes and emoji's 🙏.
            '';
        };
    };
}
