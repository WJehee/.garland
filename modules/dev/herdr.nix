# Herdr (https://herdr.dev), the terminal multiplexer the agents of
# ./agents.nix run side by side in, plus two helpers that drive it over its
# socket CLI:
#
# - herdr-dictate toggles speech input: the first call starts recording from
#   the default PipeWire source and remembers which herdr pane was focused,
#   the second stops, transcribes locally with whisper.cpp and types the text
#   into that pane without pressing Enter, so it can be reviewed first. Bound
#   to prefix+d inside herdr (ctrl+b, then d, once to start, again to stop)
#   and to mod+shift+d in Hyprland, which works from any window.
# - herdr-dev [dir] [command...] opens a workspace for a project: the command
#   (claude by default) on the left, a shell on the right, both in dir.
#
# The target pane is resolved when recording starts, not when it stops, so
# moving focus while speaking does not send the text somewhere else.
{
    flake.modules.homeManager.dev = { lib, pkgs, ... }: let
        # English-only small model, 5-bit quantized (about 180 MB). The .en
        # models are more accurate than the multilingual ones of the same
        # size for English, which is what the agents get prompted in; swap
        # for ggml-small-q5_1.bin (and drop `-l en` below) to dictate in
        # other languages. Larger models transcribe noticeably slower on the
        # laptop's iGPU.
        model = pkgs.fetchurl {
            url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en-q5_1.bin";
            hash = "sha256-v9/0iU3Ldrv2R9ViY+oqlmRUI/FmkXb0hEob+OR4rTA=";
        };

        herdr-dictate = pkgs.writeShellApplication {
            name = "herdr-dictate";
            # Vulkan runs on both the nvidia and the intel hosts, unlike
            # CUDA, and ggml falls back to the CPU without a Vulkan device
            runtimeInputs = [ pkgs.herdr pkgs.whisper-cpp-vulkan pkgs.pipewire pkgs.jq pkgs.coreutils pkgs.util-linux pkgs.gnused pkgs.libnotify ];
            text = ''
                state="''${XDG_RUNTIME_DIR:-/tmp}/herdr-dictate"
                mkdir -p "$state"
                audio="$state/audio.wav"

                notify() {
                    # A desktop notification rather than a herdr toast, since
                    # the Hyprland binding fires while herdr may not be visible.
                    # Each one replaces the previous, so "Recording" turns into
                    # "Transcribing" instead of stacking up.
                    local id=0
                    [[ -f "$state/notification" ]] && id=$(<"$state/notification")
                    notify-send -a herdr-dictate -p -r "$id" "Dictation" "$1" > "$state/notification" 2>/dev/null || true
                }

                if [[ -f "$state/pid" ]] && kill -0 "$(<"$state/pid")" 2>/dev/null; then
                    pid=$(<"$state/pid")
                    pane=$(<"$state/pane")
                    rm -f "$state/pid"

                    # SIGINT, not SIGTERM: pw-record only writes the final
                    # WAV header sizes on a clean shutdown
                    kill -INT "$pid"
                    while kill -0 "$pid" 2>/dev/null; do sleep 0.05; done

                    notify "Transcribing"
                    # whisper marks silence and noise with bracketed tags
                    # such as [BLANK_AUDIO], which should not be typed
                    text=$(whisper-cli -m ${model} -l en -nt -np -f "$audio" 2>/dev/null \
                        | sed -e 's/\[[^]]*\]//g' | tr -s '\n ' '  ' | sed -e 's/^ *//' -e 's/ *$//')
                    rm -f "$audio"

                    if [[ -n "$text" ]]; then
                        herdr pane send-text "$pane" "$text" >/dev/null
                    else
                        notify "No speech recognized"
                    fi
                else
                    if ! pane=$(herdr pane current 2>/dev/null | jq -er '.result.pane.pane_id'); then
                        notify "herdr is not running"
                        exit 1
                    fi
                    printf '%s' "$pane" > "$state/pane"

                    # whisper.cpp expects 16 kHz mono. setsid detaches the
                    # recorder from herdr's process group so it outlives this
                    # script; as a background job it is not a group leader,
                    # so setsid execs in place and $! is pw-record's pid.
                    setsid pw-record --rate 16000 --channels 1 --format s16 "$audio" &
                    echo $! > "$state/pid"
                    notify "Recording, press again to stop"
                fi
            '';
        };

        herdr-dev = pkgs.writeShellApplication {
            name = "herdr-dev";
            runtimeInputs = [ pkgs.herdr pkgs.jq pkgs.coreutils ];
            text = ''
                dir=$(realpath "''${1:-.}")
                shift || true
                if [[ $# -eq 0 ]]; then set -- claude; fi

                ws=$(herdr workspace create --cwd "$dir" --label "$(basename "$dir")" --focus)
                agent=$(jq -er '.result.root_pane.pane_id' <<<"$ws")
                herdr pane split "$agent" --direction right --cwd "$dir" --no-focus >/dev/null
                herdr pane run "$agent" "$*" >/dev/null
            '';
        };
    in {
        home.packages = [ pkgs.herdr herdr-dictate herdr-dev ];

        # Merges into the binds of modules/workstation/hyprland/hyprland.nix,
        # whose Lua config defines mainMod. Inert on hosts without Hyprland.
        wayland.windowManager.hyprland.settings.bind = [
            { _args = [
                (lib.generators.mkLuaInline ''mainMod .. " + SHIFT + D"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${lib.getExe herdr-dictate}")'')
            ]; }
        ];

        # In the context of a declarative home, facing herdr's settings UI
        # and `herdr config reset-keys` writing to config.toml, we chose a
        # read-only store symlink to keep keybindings and theme in this
        # repo, accepting that changes made from inside herdr fail and have
        # to be made here instead. Reload after a switch with prefix+shift+r.
        #
        # force, because herdr writes config.toml itself (on first launch,
        # from the settings UI) and may replace the symlink with a regular
        # file, which would otherwise fail every later activation with
        # "would be clobbered". Whatever herdr wrote there is discarded.
        xdg.configFile."herdr/config.toml".force = true;
        xdg.configFile."herdr/config.toml".source = (pkgs.formats.toml {}).generate "herdr-config.toml" {
            # The onboarding writes its choice back to this file
            onboarding = false;
            # Follows the terminal palette, so stylix colours herdr too
            theme.name = "terminal";
            ui.toast.delivery = "herdr";
            keys.command = [
                {
                    key = "prefix+d";
                    type = "shell";
                    command = lib.getExe herdr-dictate;
                }
            ];
        };
    };
}
