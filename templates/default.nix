{
    default = {
        path = ./default;
        description = "Default project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
        '';
    };
    rust = {
        path = ./rust;
        description = "A rust project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
        '';
    };
    zig = {
        path = ./zig;
        description = "A zig project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - zig init
        '';
    };
    elixir = {
        path = ./elixir;
        description = "An elixir project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - mix new .
        '';
    };
    python = {
        path = ./python;
        description = "A python project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - uv init
        '';
    };
    gleam = {
        path = ./gleam;
        description = "A gleam project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - gleam new .
        '';
    };
    android = {
        path = ./android;
        description = "An android project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - create the project in this directory with Android Studio
        '';
    };
    github-ci = {
        path = ./github-ci;
        description = "Add-on: GitHub Actions nix build workflow";
        welcomeText = ''
            Added .github/workflows/ci.yml (nix build).
            See the comments in the workflow for CI secrets via secretspec + sops.
        '';
    };
    rust-fuzz = {
        path = ./rust-fuzz;
        description = "Add-on: LibAFL fuzzing skeleton for a rust project";
        welcomeText = ''
            Added fuzz/ (standalone LibAFL workspace, cargo-fuzz style layout).

            - point the harness in fuzz/src/main.rs at your crate
              (uncomment the path dependency in fuzz/Cargo.toml)
            - rename the crate if the project is not named changeme:
              sed -i "s/changeme/<name>/g" fuzz/Cargo.toml
            - run: cargo run --manifest-path fuzz/Cargo.toml --release
        '';
    };
    rust-supply-chain = {
        path = ./rust-supply-chain;
        description = "Add-on: cargo-vet, cargo-deny and cargo-supply-chain config for a rust project";
        welcomeText = ''
            Added supply-chain/ (cargo-vet), deny.toml (cargo-deny) and
            .github/workflows/supply-chain.yml.

            - add cargo-vet, cargo-deny and cargo-supply-chain to packages in devenv.nix
            - set `publish = false` or a `license` in Cargo.toml, or cargo-deny
              reports the crate itself as unlicensed
            - baseline existing dependencies as exemptions and fetch the imported
              audits, then commit supply-chain/ (CI runs with --locked):
                cargo vet regenerate exemptions && cargo vet
            - justfile recipes: `cargo deny check`, `cargo vet`, `cargo vet suggest`,
              `cargo supply-chain publishers`
        '';
    };
    codeql-ci = {
        path = ./codeql-ci;
        description = "Add-on: GitHub Actions CodeQL analysis workflow";
        welcomeText = ''
            Added .github/workflows/codeql.yml.
            Set the language matrix in the workflow to match the project.
        '';
    };
    semgrep-ci = {
        path = ./semgrep-ci;
        description = "Add-on: GitHub Actions semgrep scan workflow";
        welcomeText = ''
            Added .github/workflows/semgrep.yml (semgrep scan --config auto).
        '';
    };
}
