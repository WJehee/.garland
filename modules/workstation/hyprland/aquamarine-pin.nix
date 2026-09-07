# aquamarine 0.15.0 never disables the kernel CRTC of a display that goes
# away: Hyprland's disable commit is refused with "Cannot commit a
# disconnected output", so the CRTC stays bound to the dead connector. The
# next monitor that gets handed that CRTC fails every modeset with EINVAL and
# sits at 0x0 with no signal (foxglove after docking, 2026-09-04 and
# 2026-09-07; recoverable only by a VT round-trip). 0.14.0 does not have the
# guard. Regression from async commits, hyprwm/aquamarine#363, tracked in
# https://github.com/hyprwm/aquamarine/issues/386.
# TODO: drop this pin once nixpkgs ships an aquamarine with the fix.
{
    flake.modules.nixos.workstation = {
        nixpkgs.overlays = [
            (final: prev: {
                aquamarine = prev.aquamarine.overrideAttrs (old: rec {
                    version = "0.14.0";
                    src = final.fetchFromGitHub {
                        owner = "hyprwm";
                        repo = "aquamarine";
                        tag = "v${version}";
                        hash = "sha256-YMh/llUAd7ENxYQozt8oZEUcD9jlZHIKYDVbOeVkh8Y=";
                    };
                });
            })
        ];
    };
}
