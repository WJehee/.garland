{ pkgs, ... }:
{
    languages.typst = {
        enable = true;
        # The editor runs its own tinymist (see garland's
        # modules/workstation/typst.nix); a second copy in the shell would
        # only shadow it.
        lsp.enable = false;
        # Fonts beyond the system ones, e.g. [ "${pkgs.roboto}/share/fonts/truetype" ]
        fontPaths = [ ];
    };

    packages = with pkgs; [
        typstyle
    ];
}
