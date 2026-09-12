{
    flake.modules.nixos.workstation = {
        # Fallback order for glyphs the terminal font lacks. Alacritty sizes a
        # cell by the base character and ignores variation selector 16, so
        # text-presentation symbols like U+2139 (info) and U+26A0 (warning)
        # must come from a monospace text font or the two-column color glyph
        # gets clipped into one cell. Wide emoji such as U+1F680 (rocket) are
        # missing from those fonts and reach Noto Color Emoji. Without this
        # rule they land on Unifont and FreeMono as monochrome glyphs, since
        # both are monospace and outrank the proportional emoji font.
        #
        # Alacritty also draws zero-width characters with the same fallback
        # walk, and none of the fonts above map U+FE0F itself, so the
        # selector would otherwise be drawn with Unifont's visible glyph for
        # it. DejaVu Sans comes last to supply an empty glyph without taking
        # any symbol away from the emoji font.
        #
        # TODO: drop the DejaVu Sans Mono, FreeMono and DejaVu Sans entries
        # once alacritty widens cells for emoji variation selector sequences
        # and stops drawing the selector, so those symbols render as color
        # emoji too. Tracked in
        # https://github.com/alacritty/alacritty/issues/481; verify with
        # `nix run nixpkgs#deploy-rs -- path:.#hemlock --dry-activate`
        # and check that the info sign in the log prefix is not clipped.
        fonts.fontconfig.localConf = ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
            <fontconfig>
                <match target="pattern">
                    <edit name="family" mode="append" binding="strong">
                        <string>DejaVu Sans Mono</string>
                        <string>FreeMono</string>
                        <string>Noto Color Emoji</string>
                        <string>DejaVu Sans</string>
                    </edit>
                </match>
            </fontconfig>
        '';
    };
}
