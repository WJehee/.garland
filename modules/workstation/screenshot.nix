# Screenshots: select a region, annotate it in satty, then save and copy only
# what you keep.
{
    flake.modules.homeManager.hyprland = { lib, pkgs, ... }: let
        inherit (lib.generators) mkLuaInline;

        screenshot-edit = pkgs.writeShellApplication {
            name = "screenshot-edit";
            runtimeInputs = with pkgs; [ hyprshot satty wl-clipboard libnotify coreutils ];
            text = ''
                dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
                mkdir -p "$dir"
                file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

                # Capture to a temp file first: cancelling the region selection
                # (Escape) makes hyprshot exit non-zero with nothing on stdout,
                # and satty would otherwise open on an empty image
                raw="$(mktemp --suffix .png)"
                trap 'rm -f "$raw"' EXIT
                hyprshot -m region -z -r -s > "$raw" || exit 0
                [ -s "$raw" ] || exit 0

                # Ctrl+S / Enter saves and exits; Ctrl+C copies, saves and exits
                satty --filename "$raw" \
                    --output-filename "$file" \
                    --copy-command wl-copy \
                    --save-after-copy \
                    --early-exit \
                    --initial-tool arrow \
                    --disable-notifications

                if [ -s "$file" ]; then
                    notify-send -a Screenshot -i "$file" "Screenshot saved" "$(basename "$file")"
                fi
            '';
        };

        bind = keys: cmd: { _args = [ keys (mkLuaInline ''hl.dsp.exec_cmd("${cmd}")'') ]; };
        mod = combo: mkLuaInline ''mainMod .. " + ${combo}"'';
    in {
        home.packages = [ screenshot-edit ];

        wayland.windowManager.hyprland.settings.bind = [
            (bind (mod "SHIFT + S") "screenshot-edit")
            (bind "Print" "screenshot-edit")
        ];

        # Float the satty editor centered on the current monitor; mkAfter
        # keeps it behind the tile-everything catch-all rule in hyprland.nix
        wayland.windowManager.hyprland.settings.window_rule = lib.mkAfter [
            {
                match = { class = "com.gabm.satty"; };
                float = true;
                center = true;
            }
        ];
    };
}
