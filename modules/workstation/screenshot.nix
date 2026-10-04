# Screenshots: select a region, annotate it in satty, then save and copy only
# what you keep.
{
    flake.modules.homeManager.hyprland = { lib, pkgs, ... }: let
        inherit (lib.generators) mkLuaInline;

        screenshot-edit = pkgs.writeShellApplication {
            name = "screenshot-edit";
            runtimeInputs = with pkgs; [ hyprpicker slurp grim satty wl-clipboard libnotify coreutils ];
            text = ''
                dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
                mkdir -p "$dir"
                file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

                # slurp and grim are called directly rather than through
                # hyprshot: hyprshot runs its capture as a background job and
                # exits as soon as the slurp overlay closes, so with --raw the
                # image reaches stdout after hyprshot has already returned and
                # the file below is still empty when it is checked. The freeze
                # works like hyprshot's: hyprpicker paints a frozen copy of the
                # screen over everything, slurp selects on that still image and
                # grim captures the overlay. The short sleep gives hyprpicker
                # time to map its layer before slurp maps its own on top
                hyprpicker --render-inactive --no-zoom &
                picker=$!
                raw="$(mktemp --suffix .png)"
                trap 'kill "$picker" 2>/dev/null; rm -f "$raw"' EXIT
                sleep 0.2

                # Cancelling the region selection (Escape) makes slurp exit
                # non-zero; stop quietly instead of opening satty on nothing
                geometry=$(slurp -d) || exit 0
                grim -g "$geometry" "$raw"
                kill "$picker" 2>/dev/null
                [ -s "$raw" ] || exit 0

                # Ctrl+S / Enter saves and exits; Ctrl+C copies, saves and exits.
                # satty always pipes PNG bytes to the copy command. The type is
                # set explicitly because a bare wl-copy guesses it through
                # xdg-mime and falls back to text/plain, which browsers and
                # Electron apps (Signal, WhatsApp Web) refuse to paste as an image
                satty --filename "$raw" \
                    --output-filename "$file" \
                    --copy-command "wl-copy --type image/png" \
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
