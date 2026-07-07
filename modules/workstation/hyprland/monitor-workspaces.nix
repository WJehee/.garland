# Dynamically pin workspaces to monitors based on what is connected, using
# native Hyprland Lua monitor events (replaces the old socat-based
# hypr-monitor-workspaces shell daemon).
#
# The host declares `monitorWorkspaces.profiles`: an ordered list of layouts,
# the first one whose `when` monitors are all connected wins. Monitors are
# referenced by a substring of their description; "*" stands for any connected
# monitor that no named entry in the profile matched.
{
    flake.modules.homeManager.monitor-workspaces = { config, lib, ... }: let
        inherit (lib) mkOption types;

        band = types.submodule {
            options = {
                monitor = mkOption {
                    type = types.str;
                    description = "Description substring of the target monitor, or \"*\".";
                };
                from = mkOption {
                    type = types.ints.positive;
                    description = "First workspace of the band; it becomes the monitor's default.";
                };
                to = mkOption {
                    type = types.ints.positive;
                    description = "Last workspace of the band (inclusive).";
                };
                extra = mkOption {
                    type = types.attrs;
                    default = { };
                    description = "Extra workspace rule fields, e.g. layout_opts.";
                };
            };
        };

        profile = types.submodule {
            options = {
                when = mkOption {
                    type = types.listOf types.str;
                    default = [ ];
                    description = "Monitors that must be connected for this profile to apply.";
                };
                bands = mkOption {
                    type = types.listOf band;
                    description = "Workspace ranges to pin per monitor.";
                };
            };
        };
    in {
        options.monitorWorkspaces.profiles = mkOption {
            type = types.listOf profile;
            default = [ ];
            description = "Workspace layouts to try in order; first match wins.";
        };

        config.wayland.windowManager.hyprland.extraLuaFiles."monitor-workspaces.lua" = ''
            local profiles = ${lib.generators.toLua { indent = "    "; } config.monitorWorkspaces.profiles}

            -- Resolve the current port name (e.g. "DP-6") from a substring of a
            -- monitor description. Returns nil when nothing connected matches.
            local function find_monitor(desc)
                for _, m in ipairs(hl.get_monitors()) do
                    if m.description and m.description:find(desc, 1, true) then
                        return m.name
                    end
                end
                return nil
            end

            -- Ids of workspaces that currently exist, so we only relocate open
            -- ones (moving a non-existent workspace just logs a warning).
            local function open_workspaces()
                local open = {}
                for _, w in ipairs(hl.get_workspaces()) do
                    open[w.id] = true
                end
                return open
            end

            -- Map every monitor referenced by a profile to a connected port name.
            -- "*" resolves to the first connected monitor no named entry matched.
            -- Returns nil when a `when` requirement is not connected.
            local function resolve(profile)
                local descs = {}
                for _, d in ipairs(profile.when) do descs[d] = true end
                for _, b in ipairs(profile.bands) do descs[b.monitor] = true end

                local names, used = {}, {}
                for d in pairs(descs) do
                    if d ~= "*" then
                        names[d] = find_monitor(d)
                        if names[d] then used[names[d]] = true end
                    end
                end
                if descs["*"] then
                    for _, m in ipairs(hl.get_monitors()) do
                        if not used[m.name] then
                            names["*"] = m.name
                            break
                        end
                    end
                end

                for _, d in ipairs(profile.when) do
                    if not names[d] then return nil end
                end
                return names
            end

            local function setup_workspaces()
                local open = open_workspaces()

                -- Pin a workspace to a monitor. opts may carry extra rule fields
                -- such as `default` or `layout_opts`.
                local function assign(ws, monitor, opts)
                    if not monitor then return end
                    local rule = { workspace = tostring(ws), monitor = monitor }
                    for k, v in pairs(opts) do rule[k] = v end
                    hl.workspace_rule(rule)
                    if open[ws] then
                        hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(ws), monitor = monitor }))
                    end
                end

                for _, profile in ipairs(profiles) do
                    local names = resolve(profile)
                    if names then
                        for _, b in ipairs(profile.bands) do
                            for ws = b.from, b.to do
                                -- The first workspace of a band is the monitor's
                                -- default, shown when it (re)connects or is emptied.
                                local opts = { default = ws == b.from }
                                for k, v in pairs(b.extra) do opts[k] = v end
                                assign(ws, names[b.monitor], opts)
                            end
                        end
                        return
                    end
                end
            end

            -- On hotplug the monitor description is not always populated
            -- immediately, so defer a touch to let it settle (the old daemon
            -- polled for the same reason).
            local function setup_soon()
                hl.timer(setup_workspaces, { timeout = 250, type = "oneshot" })
            end

            hl.on("hyprland.start",  setup_workspaces)
            hl.on("monitor.added",   setup_soon)
            hl.on("monitor.removed", setup_soon)
        '';
    };
}
