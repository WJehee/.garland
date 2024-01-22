{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        python3Full
        python311Packages.jedi-language-server
        rustup
        clippy
        rustfmt
        cargo
        cargo-generate
        cargo-watch
        gcc
        clang-tools
        git
        nodejs
        docker
        docker-compose
        nil
        elixir
        elixir-ls
        just
    ];
}
