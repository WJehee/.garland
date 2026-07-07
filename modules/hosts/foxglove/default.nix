# Framework laptop
{ config, ... }: let
    nixos = config.flake.modules.nixos;
    hm = config.flake.modules.homeManager;
in {
    flake.modules.nixos."hosts/foxglove" = {
        imports = [
            ./_hardware-configuration.nix
            nixos.base
            nixos.home-manager
            nixos.workstation
            nixos."disk/luks-lvm"
            nixos."gpu/intel"
            nixos.hacking
            nixos."3d-printing"
            nixos.tailscale
            nixos.music
            nixos.llm
            nixos.cad
            nixos.dev
            nixos.virtualization
        ];

        networking.hostName = "foxglove";
        boot.kernelParams = [ "i915.force_probe=46a6" ];
        stylix.image = ../../../wallpapers/foxglove-landscape.jpg;

        home-manager.users.wouter = {
            imports = [
                hm.workstation
                hm.hyprland
                hm.shell
                hm.dev
            ];
            # DO NOT CHANGE THIS after first install
            home.stateVersion = "26.11";

            wayland.windowManager.hyprland = {
                settings.monitor = [
                    { output = ""; mode = "preferred"; position = "auto"; scale = 1; }
                    { output = "desc:BOE NE135A1M-NY1"; mode = "preferred"; position = "auto"; scale = 1.2; }
                    { output = "desc:Dell Inc. DELL P2416D 6RC2C5BB08FL"; mode = "preferred"; position = "auto-left"; scale = 1; transform = 1; }
                    { output = "desc:Dell Inc. DELL P2720D JV69F9AP02VS"; mode = "preferred"; position = "auto-left"; scale = 1; }
                ];

                # Dynamically pin workspaces to monitors based on what is connected.
                # Replaces the old socat-based hypr-monitor-workspaces shell daemon with
                # native Hyprland Lua monitor events.
                extraLuaFiles."monitor-workspaces.lua" = ''
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

                    local function setup_workspaces()
                        local open = open_workspaces()

                        -- Pin a workspace to a monitor. opts may carry extra rule fields
                        -- such as `default` or `layout_opts`.
                        local function assign(ws, monitor, opts)
                            if not monitor then return end
                            local rule = { workspace = tostring(ws), monitor = monitor }
                            if opts then
                                for k, v in pairs(opts) do rule[k] = v end
                            end
                            hl.workspace_rule(rule)
                            if open[ws] then
                                hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(ws), monitor = monitor }))
                            end
                        end

                        -- Assign a contiguous range to a monitor, marking the first as
                        -- that monitor's default so it is shown when the monitor
                        -- (re)connects or is emptied.
                        local function band(first, last, monitor, extra)
                            for ws = first, last do
                                local opts = { default = ws == first }
                                if extra then
                                    for k, v in pairs(extra) do opts[k] = v end
                                end
                                assign(ws, monitor, opts)
                            end
                        end

                        local laptop   = find_monitor("BOE")
                        local primary  = find_monitor("P2720D")
                        local portrait = find_monitor("P2416D")

                        if primary and portrait then
                            -- Docked: spread workspaces across the external monitors.
                            band(1, 5, primary)
                            band(6, 9, portrait, { layout_opts = { orientation = "top" } })
                            assign(10, laptop, { default = true })
                        else
                            -- Any single external monitor: 1-7 on laptop, 8-10 on external.
                            local ext
                            for _, m in ipairs(hl.get_monitors()) do
                                if m.name ~= laptop then
                                    ext = m.name
                                    break
                                end
                            end
                            if ext then
                                band(1, 7, laptop)
                                band(8, 10, ext)
                            else
                                -- Undocked: everything on the laptop screen.
                                band(1, 10, laptop)
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
            xdg.configFile."hypr/hyprpaper.conf".text = ''
                splash = 0

                wallpaper {
                    monitor = desc:BOE NE135A1M-NY1
                    path = ${../../../wallpapers/foxglove-landscape.jpg}
                    fit_mode = cover
                }

                wallpaper {
                    monitor = desc:Dell Inc. DELL P2416D 6RC2C5BB08FL
                    path = ${../../../wallpapers/foxglove-portrait.jpg}
                    fit_mode = cover
                }

                wallpaper {
                    monitor = desc:Dell Inc. DELL P2720D JV69F9AP02VS
                    path = ${../../../wallpapers/foxglove-landscape.jpg}
                    fit_mode = cover
                }
            '';
        };
    };
}
